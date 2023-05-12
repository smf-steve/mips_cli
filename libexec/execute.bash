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

  print_R_encoding $_op $_rs $_rt $rd $_shamt
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


### Syntax
##alias ArithLog
##alias ArithLogI
##alias Shift
##alias ShiftV

##alias MoveX
##alias DivMult

##alias LoadI
##alias LoadStore
##alias Branch
##alias BranchZ
##alias Jump
##alias JumpR
execute_instructions=TRUE
emit_execution_summary=TRUE

alias execute_ArithLog=execute_RRR
function execute_RRR() {
  local _name="$1"
  local _op="$2"
  local _rd="$(sed -e 's/,$//' <<< $3)"
  local _rs="$(sed -e 's/,$//' <<< $4)"
  local _rt="$(sed -e 's/,$//' <<< $5)"
  local _shamt="0"
  local _rt_prefix=""
  local _carry_in=0
  local _value

  print_R_encoding $_name $_rs $_rt $_rd $_shamt
  [[ ${execute_instructions} == "TRUE" ]] || return

  case $_op in
      +) reset_cin
         ;;

      -) set_cin
           _op="+"
           _rt_prefix="~"
           _carry_in=1
         ;;

      *) unset_cin
         ;;
  esac

  _rs_value=$(rval $_rs)
  _rt_value=${_rt_prefix}$(rval $_rt)
  LATCH_A=($_rs $_rs_value )
  LATCH_B=($_rt $_rt_value )

  _value=$(( ( _rs_value $_op _rt_value ) + _carry_in ))
  assign $_rd $_value $_rs_value $_rt_value

  print_ALU_state "$_op" $_rd
  unset_cin
}

alias execute_ArithLogI=execute_RRI
function execute_RRI () {
  local _name="$1"
  local _op="$2"
  local _rt="$(sed -e 's/,$//' <<< $3)"
  local _rs="$(sed -e 's/,$//' <<< $4)"
  local _text="$5"
  local _imm=$(read_immediate "$_text")
  local _literal=$(sign_extension "$_imm")
  local _value

  print_I_encoding $_name $_rs $_rt $_imm
  [[ ${execute_instructions} == "TRUE" ]] || return

  if [[ $_op == "+" ]] ; then 
    reset_cin
  fi

  local _rs_value=$(rval $_rs)
  LATCH_A=( $_rs $_rs_value )
  LATCH_B=( imm ${_literal} "$_text" )

  _value=$(( _rs_value $_op _literal ))
  assign $_rt $_value $_rs_value $_literal

  print_ALU_state "$_op" $_rt
  unset_cin
}

function execute_Shift () {
  # Effectively the syntax of a ArithLogI
  # but with a R format
  local _name="$1"
  local _op="$2"
  local _func_op="$(sed -e 's/>>>/>>/' <<< $_op)"
  local _rd="$(sed -e 's/,$//' <<< $3)"
  local _rt="$(sed -e 's/,$//' <<< $4)"
  local _text="$5"
  local _shamt=$(read_shamt "$_text")
  local _value

  print_R_encoding $_name "0" $_rt $_rd $_shamt
  [[ ${execute_instructions} == "TRUE" ]] || return

  local _rt_value=$(rval $_rt)
  LATCH_A=( $_rt $_rt_value )
  LATCH_B=( imm ${_shamt} "$_text" )

  if [[ $_op != ">>" ]] ; then
    # We are doing srl, we need to clear
    # the top most bits
    _rt_value=$(( _rt_value & 0xFFFFFFFF ))
  fi
  _value=$(( _rt_value $_func_op _shamt ))
  if (( _value > max_word )) ; then
    # we need to drop off the shifted bits
    _value=$(( _value & 0xFFFFFFFF ))
  fi
  assign $_rd $_value $_rt_value $_shamt 

  print_ALU_state "$_op" $_rd
}

function execute_ShiftV () {
  local _name="$1"
  local _op="$2"
  local _func_op="$(sed -e 's/>>>/>>/' <<< $_op)"
  local _rd="$(sed -e 's/,$//' <<< $3)"
  local _rt="$(sed -e 's/,$//' <<< $4)"
  local _rs="$(sed -e 's/,$//' <<< $5)"

  print_R_encoding $_name "$_rs" $_rt $_rd "0"
  [[ ${execute_instructions} == "TRUE" ]] || return

  local _rt_value=$(rval $_rt)
  local _rs_value=$(rval $_rs)
  LATCH_A=( $_rt $_rt_value )
  LATCH_B=( $_rs $_rs_value )

  if [[ $_op != ">>" ]] ; then
    # We are doing srlv, we need to clear
    # the top most bits
    _rt_value=$(( _rt_value & 0xFFFFFFFF ))
  fi
  _value=$(( _rt_value $_func_op _rs_value ))
  if (( _value > max_word )) ; then
    # we need to drop off the shifted bits
    _value=$(( _value & 0xFFFFFFFF ))
  fi

  assign $_rd $_value $_rt_value $_rs_value 

  print_ALU_state "$_op" $_rd
}


function execute_MoveTo ()  {
	# Example: mthi move _hi
  local _name="$1"
  local _op="$2"
  local _dst="$(sed -e 's/,$//' <<< $3)"
  local _src="$4"

  case $_name in
     mt*)  print_R_encoding $_name $_src "0" "0" "0"
           ;;
     mf*)  print_R_encoding $_name "0" "0" $_dst "0"
           ;;
  esac

  [[ ${execute_instructions} == "TRUE" ]] || return

  LATCH_A=($_src $(rval $_src) )
  LATCH_B=()
  assign "$_dst" "$(rval $_src)"

  print_ALU_state "$_op" $_dst
}

function execute_MoveFrom() {
  execute_MoveTo $1 $2 $4 $3
}

function execute_MD () {
  local _name="$1"
  local _op="$2"
  local _rs _src1="$(sed -e 's/,$//' <<< $3)"
  local _rt _src2="$4"

  print_R_encoding $_name $_rs $_rt "0" "0"
  [[ ${execute_instructions} == "TRUE" ]] || return


  local _rs_value=$(rval $_rs)
  local _rt_value=$(rval $_rt)

  case $_name in
     *u) # Use 32-bits as unsigned
         _rs_value=$(( _rs_value & 0xFFFFFFFF ))
         _rt_value=$(( _rt_value & 0xFFFFFFFF ))
         ;;
  esac

  LATCH_A=( $_rs $_rt_value )
  LATCH_B=( $_rt $_rt_value )

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

