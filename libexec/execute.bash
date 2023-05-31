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


# Presume we have a front't that changes things.
# Syntax:
#   line:          [ label:] [instruction  #comment]   
#   instruction:   op one two three four
#   instruction:   op one two (three)              <-- force
#   instruction:   op ( one two three four .... )  <-- force  macro
#      note commas are optional but must be part of the token
#      allow the current engine deal with the immediates and comments

declare -i line_num=0

function step_execute () {
  labels=()
  local label
  local instruction 

  read label instruction 

  # If the line is just a label then 
  while [[ "${label:((${#label}-1))}" == ":" && -z "$instruction" ]] ; do
    labels+=( ${label} )
    (( line_num++ ))

    read label instruction 
  done
  
  number_labels=${#labels[@]}
  for (( i=0 ; i < ${number_labels} ; i++ )) ; do
     # This loop processes just the labels on blank lines
     local this_label=${labels[$i]}
     local name=${this_label:0:((${#this_label}-1))} # strip the ":" at the end
     assign_text_label ${name} 
  done

  if [[ "${label:((${#label}-1))}" != ":" ]] ; then
    instruction="$label $instruction"
  else 
    local name=${label:0:((${#label}-1))}  # strip the ":" at the end
    assign_text_label ${name} 
  fi

  (( line_num++ ))
  (( REGISTER[$_pc]++ ))         # Maybe this is really npc
  eval $instruction

}




function execute () {
  _filename="$1"

  [[ -f $_filename ]] ||  { echo "$_filename not found" ; return 1; }
  while read _line; do
    echo $_line
    eval $_line
    sleep 1
  done < $_filename
}

################################################################################



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

  print_R_encoding $_name $_rs $_rt $_rd $_shamt
  [[ ${execute_instructions} == "TRUE" ]] || return

  local _carry_in=0
  local _rt_prefix=""
  local _value

  case $_op in
      +) reset_cin
         ;;

      -) set_cin
           _op="+"
           _carry_in=1
           _rt_prefix="~"
         ;;

      *) unset_cin
         ;;
  esac

  local _rs_value=$(rval $_rs)
  local _rt_value=${_rt_prefix}$(rval $_rt)
  LATCH_A=($_rs $_rs_value )
  LATCH_B=(${_rt_prefix}$_rt ${_rt_prefix}$_rt_value ) 

  case $_name in
     slt*u) # Use 32-bits as unsigned
         _rs_value=$(( _rs_value & 0xFFFFFFFF ))
         _rt_value=$(( _rt_value & 0xFFFFFFFF ))
         ;;
  esac

  case "$_op" in
    "~|")  _value=$(( ~ ( _rs_value | _rt_value ) ))
           ;;
       *)  _value=$(( ( _rs_value $_op _rt_value ) + _carry_in ))
           ;;
  esac

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

  if (( $_rs_value >= 32 || $_rs_value < 0 )) ; then
    _msg="Notice: the value of \$$(name $_rs) is not in the range 0..31"
    instruction_warning "$_msg"
  fi

  LATCH_A=( $_rt $_rt_value )
  LATCH_B=( $_rs $_rs_value )

  if [[ $_op != ">>" ]] ; then
    # We are doing srlv, we need to clear
    # the top most bits
    _rt_value=$(( _rt_value & 0xFFFFFFFF ))
  fi
  _value=$(( _rt_value $_func_op _rs_value ))
  if (( _value > max_word  || _value < - max_word )) ; then
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
  local _rs="$(sed -e 's/,$//' <<< $3)"
  local _rt="$4"

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

  LATCH_A=( $_rs $_rs_value )
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


# Syntax: name rt imm
function execute_LoadI () {
  # Usage: name -- rt, im
  # Herre the immediate is a word...??
  echo "Bug in this code"

  local _name="$1"
  local _op="$2"
  local _rt="$(sed -e 's/,$//' <<< $3)"
  local _text="$4"
  local _imm=$(read_immediate "$_text")
  local _literal=$(sign_extension "$_imm")
  local _value

  ## Print the Encoding
  print_I_encoding $_name $zero $_rt $_imm $_text
  [[ ${execute_instructions} == "TRUE" ]] || return

  # Determine value 
  case $_name in 
    lui|lhi)
         _value=$(( $_imm << 16 ))
         ;;
    llo) _value=$(( $_imm ))
         ;;
  esac

  LATCH_A=()
  LATCH_B=( imm ${_literal} "$_text" )
  assign "$_rt" "$_value"

  print_ALU_state "$_op" $_rt
}

function execute_Branch () {
  local _name="$1"
  local _op="$2"
  local _rs="$(sed -e 's/,$//' <<< $3)"
  local _rt="$(sed -e 's/,$//' <<< $4)"
  local _label="$5"
  
  local _imm=$(encode_offset $_label)

  ## Print the Encoding
  {
    print_I_encoding $_name $_rs $_rt $_imm $_label

    emit_p=${emit_encodings}
    emit_encodings=FALSE
    execute_ArithLog "sub" "-" $zero $_rs $zero 
    emit_encodings=$emit_p

  }
  [[ ${execute_instructions} == "TRUE" ]] || return

  local _current=${REGISTER[$_pc]}
  local _addr=$(lookup_text_label $_label)

  case "$_name" in 
    beq) if [[ ${STATUS_BITS[$_z_bit]} == "1" ]] ; then
           REGISTER[$_pc]=$_addr
         else
           :
         fi
         ;;
    bne) if [[ ${STATUS_BITS[$_z_bit]} == "0" ]] ; then
           REGISTER[$_pc]=$_addr
         else
           :
         fi
         ;;
  esac
  print_PC_update "mux" ${STATUS_BITS[$_z_bit]} $_current  $_addr $_label
  echo "Not Implemented"

}


function execute_BranchZ () {
  local _name="$1"
  local _op="$2"
  local _rs="$(sed -e 's/,$//' <<< $3)"
  local _label="$4"

  ## Print the Encoding
  {
    print_I_encoding $_name $_rs $_rt $_imm $_label

    emit_p=${emit_encodings}
    emit_encodings=FALSE
    execute_ArithLog "add" "-" $_zero $_rs $_zero 
    emit_encodings=$emit_p
  }
  [[ ${execute_instructions} == "TRUE" ]] || return

  local _current=${REGISTER[$_pc]}
  local _addr=$(lookup_text_label $_label)

  case "$_name" in 
    bgtz) if [[ ${STATUS_BITS[$_s_bit]} == 0 && ${STATUS_BITS[$_z_bit]} == 0 ]] ; then 
             # result is positive, hence '$_rs > 0'
             REGISTER[$_pc]=$_addr
          else
            :
          fi
          ;;
    blez) if [[ ${STATUS_BITS[$_s_bit]} == 1 || ${STATUS_BITS[$_z_bit]} == 1 ]] ; then 
             # result is positive, hence '$_rs <= 0'
             REGISTER[$_pc]=$_addr
          else
            :
          fi
          ;;
  esac

  print_PC_update "mux" ${STATUS_BITS[$_z_bit]} $_current  $_addr $_label
  echo "Not Implemented"

}




# Syntax: name rt imm(rs)
#    Note that this function can't follow the appropriate syntax
#    As such we need to have a parser call this routine
#    Here we presume the input will followin the following
#    LoadStore name -- rt rs imm
function execute_LoadStore () {
  # Usage:  name -- rt imm (rs)
  local _name="$1"
  local _op="$2"
  local _rt="$(sed -e 's/,$//' <<< $3)"
  local _rs="$(sed -e 's/,$//' <<< $4)"
  local _text="$5"
  local _imm=$(read_immediate "$_text")
  local _literal=$(sign_extension "$_imm")
  local _value

  ## Print the Encoding
  { 
    print_I_encoding $_name $_rs $_rt $_imm

    emit_p=${emit_encodings}
    emit_encodings=FALSE
    execute_ArithLogI "addi" "+" $_mar $_rs $_imm $_text
    emit_encodings=$emit_p
  }
  [[ ${execute_instructions} == "TRUE" ]] || return


   # Determine size of the operation
   case $_name in 
      *b*) _size=1
           ;;
      *h*) _size=2
           ;;
      *)   _size=4
           ;;
   esac

   # Perform the Memory operation
   case "$_name" in
      l*)
          data_memory_read $_size
          _rt_value=$(rval $_mbr)

          case "$_name" in 
            *u) ;;
            *)  (( _size == 2 ))  &&  _rt_value=$(sign_extension "$_rt_value")
                (( _size == 1 ))  &&  _rt_value=$(sign_extension_byte "$_rt_value")
                ;;
          esac     

          assign $_rt $_rt_value   # status bits are being assigned?
          ;;
      s*)
          _rt_value=$(rval $_rt)
          assign $_mbr $_rt_value
          data_memory_write $_size
          ;;
   esac
   print_WB_stage "$_name" $_rt $_size

}


function execute_Jump () {
  # Usage:  name -- _label
  local _name="$1"
  local _op="$2"
  local _label="$(sed -e 's/,$//' <<< $3)"

  print_J_encoding $_name $_label
  [[ ${execute_instructions} == "TRUE" ]] || return

  case $_name in 
    jal) assign $ra REGISTER[$_pc]+4
        ;;
  esac
  echo REGISTER[$_pc]=$(lookup_text_label $_label)

}



function execute_JumpR () {
  # Usage:  name -- rs   # R-format
  local _name="$1"
  local _op="$2"
  local _rs="$(sed -e 's/,$//' <<< $3)"

  ## encode_R_instruction $_name $_rs "0" "0" "0"
  ## print_R_encoding $_name $_rs "0" "0" "0"
  [[ ${execute_instructions} == "TRUE" ]] || return

  case $_name in 
    jalr) assign $ra REGISTER[$_pc]+4
          ;;
  esac
  echo REGISTER[$_pc]=$(rval $_rs)

}

## Move to memory...
function print_WB_stage() {
  # Print values on the two input latches with the op and output register/s
  local _name="$1"
  local _register="$2"
  local _size="$3"


  [[ $emit_execution_summary == "TRUE" ]] || return
  case "$_name" in
    l*)
       print_mem_value "$(name $_mbr)" $(rval $_mbr) $_size
       print_op "$_name"
       print_mem_value "$(name $_register)" $(rval $_register)
       ;;
    s*)
       print_mem_value "$(name $_register)" $(rval $_register)
       print_op "$_name"
       print_mem_value "$(name $_mbr)" $(rval $_mbr) $_size
       ;;
  esac
  echo 
}


function print_mem_value () {
  local _name="$1"
  local _rval="$2"
  local _size="$3"   # The number of raw bits trnansfered

  [[ $_size == "" ]] && _size=4

  local _dec=${_rval}
  local _unsigned=$(( _rval & 0xFFFFFFFF ))
  local _hex=$(to_hex $(( _size * 2 )) $_unsigned )

  local _bin=$(to_binary "${_hex}")

  printf "   %5s:  %11d %11d; 0x%11s; 0b%39s;"  \
        "${_name}" "${_dec}" "${_unsigned}" "${_hex}" "${_bin}"
  printf "\n"
}

#     load/read:  lb
#       LATCH_IN        xxxx xxxx xxxx s???      MBR
#                 $name -------- ------   ------     
#       Latch_out       ssss ssss ssss s???      rt
#
#     store/write: sb
#       LATCH_IN        ???? ???? ???? ????     rt
#                 $name -------- ------   ------     
#       Latch_out                      ????     MBR

