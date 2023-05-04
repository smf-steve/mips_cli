#! /bin/bash
_cmd_indent=" "

function native_on () {
  :
}
function pseudo_on () {
  printf "$1 # is psuedo instruction:\n"
  CMD_INDENT="${_cmd_indent}"

}
function pseudo_off () {
  CMD_INDENT="  "
}


function .data () {
  segment=".data"
  PS1="(mips.data) "
}

function .text () {
  segment=".text"
  PS1="(mips) "
}



# HISTFILE=./.mips_cli_history


function execute () {
  _filename="$1"

  [[ -f $_filename ]] ||  { echo "$_filename not found" ; return 1; }
  while read _line; do
    echo $_line
    eval $_line
    sleep 2
  done < $_filename
}

################################################################################
# The argument list is as follows:
# execute_XXX   cmd op dst src1 src2
# execute_XXI   cmd op dst src1 imm


function execute_srl () {
  _op="$1"  # >>>
  _rd="$(sed -e 's/,$//' <<< $2)"
  _rt="$(sed -e 's/,$//' <<< $3)"
  _text="$4"
  _shamt=$(read_shamt "$_text")

  LATCH_A=($_rt $(rval $_rt) )
  LATCH_B=(imm $_shamt "$_text")

  _value=$(( $(rval $_rt) & 0xFFFFFFFF ))  
     # Sign Contraction
     # Presume that the _value was normalized to be 32 bits
     # Set the upper 33-64 buts to zero, to uliminate the sign
  _value=$(( $_value >> $_shmat  ))
  assign $_rd $_value

  print_ALU_state "$_op" $_rd
}

function execute_srlv () {
  _op="$1"  # >>>
  _rd="$(sed -e 's/,$//' <<< $2)"
  _rt="$(sed -e 's/,$//' <<< $3)"
  _rs="$4"
  _shmat=$(( $(rval $_rs) & 0x1F))  # Only the low order 5 bits.

  if [[ $(( $(rval $_rs) & (~ 0x1F) )) != 0 ]] ; then
    echo "Warning: register value contains extraneous bits"
  fi
  LATCH_A=($_rt $(rval $_rt) )
  LATCH_B=(imm $_shmat  "\$$(name $_rt) & 0x1F")

  _value=$(( $(rval $_rt) & 0xFFFFFFFF ))  
     # Sign Contraction
     # Presume that the _value was normalized to be 32 bits
     # Set the upper 33-64 buts to zero, to eliminate the sign
     # This presumes that we have 64 bit machine
  _value=$(( $_value >> $_shmat  ))
  assign $_rd $_value

  print_ALU_state "$_op" $_rd
}



function execute_nor() {
  _op="nor"  # nor
    _op1="|"   # |
    _op2="~"   # ~
  _rd="$(sed -e 's/,$//' <<< $2)"
  _rs="$(sed -e 's/,$//' <<< $3)"
  _rt="$4"

  LATCH_A=($_rs $(rval $_rs) )
  LATCH_B=($_rt $(rval $_rt) )

  _value=$(( $_op2 ( $(rval $_rs) $_op1 $(rval $_rt) ) ))
  _value=$(sign_contraction $_value)
  assign $_rd $_value

  print_ALU_state "~|" $_rd
}

function execute_RRR() {
  _op="$1"
  _rd="$(sed -e 's/,$//' <<< $2)"
  _rs="$(sed -e 's/,$//' <<< $3)"
  _rt="$4"

  _rt_prefix=""
  _carry_in=0

  unset_cin
  case $_op in
      +) reset_cin
            ;;
      -) set_cin
           _op="+"
           _rt_prefix="~"
           _carry_in=1
            ;;
     *) 
            ;;
  esac

  LATCH_A=($_rs $(rval $_rs) )
  LATCH_B=($_rt ${_rt_prefix}$(rval $_rt) )

  _value=$(( ( $(rval $_rs) $_op ${_rt_prefix}$(rval $_rt) ) + $_carry_in ))
  _value=$(sign_contraction $_value)
  assign $_rd $_value

  print_ALU_state "$_op" $_rd
  unset_cin
}

function execute_RRI () {
  _op="$1"
  _rt="$(sed -e 's/,$//' <<< $2)"
  _rs="$(sed -e 's/,$//' <<< $3)"
  _text="$4"
  _imm=$(read_immediate "$_text")
  _value=$(sign_extension "$_imm")


  LATCH_A=( $_rs $(rval $_rs) )
  LATCH_B=( imm ${_value} "$_text" )

  _value=$(( $(rval $_rs) $_op ${_value} ))
  _value=$(sign_contraction  $_value)
  assign $_rt $_value    

  print_ALU_state "$_op" $_rt

}

function execute_RR ()  {
	# Example: mthi move _hi
  _op="$1"
  _dst="$(sed -e 's/,$//' <<< $2)"
  _src="$3"

  LATCH_A=($_src $(rval $_src) )
  LATCH_B=()
  assign "$_dst" "$(rval $_src)"

  print_ALU_state "$_op" $_dst
}

function reverse_op() {
  execute_RR $1 $3 $2
}

function execute_MD () {
  _op="$1"
  _src1="$(sed -e 's/,$//' <<< $2)"
  _src2="$3"

  LATCH_A=( $_src1 $(rval $_src1) )
  LATCH_B=( $_src2 $(rval $_src2) )

  ## execute
  if [[ $_op == "*" ]] ; then 
    local _value="$(( ${LATCH_A[1]} * ${LATCH_B[1]} ))"
    assign $_lo $((  _value & 0xFFFFFFFF ))
    assign $_hi $(( (_value >> 32) & 0xFFFFFFFF ))
  else
    assign $_lo $(( ${LATCH_A[1]} / ${LATCH_B[1]} )) 
    assign $_hi $(( ${LATCH_A[1]} % ${LATCH_B[1]} )) 
  fi
  print_ALU_state "$_op" $_hi $_lo
}

