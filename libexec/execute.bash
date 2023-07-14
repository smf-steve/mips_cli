#! /bin/bash


## "execute.bash"
## Purpose:
##   - to contain all of the various functions related to "execution" of an instruction.

# Each native instruction has been grouped based upon their syntax, and general operation.
# See documentation/mips_encoding_reference.pdf for more information
#
#   execute_ArithLog 
#   execute_ArithLogI
#   execute_Shift    
#   execute_ShiftV   
#   execute_MoveTo   
#   execute_MoveFro  
#   execute_DivMult  
#   execute_LoadI    
#   execute_Branch   
#   execute_BranchZ  
#   execute_LoadStore  
#      Note a secondary syntax is only support:  "[label:]  op rt rs imm"
#      As apposed to:                            "[label:]  op rt imm ( rs )"
#   execute_Jump     
#   execute_JumpR    


function execute_ArithLog() {
  local _name="$1"
  local _op="$2"
  local _rd="${3%,}"
  local _rs="${4%,}"
  local _rt="${5%,}"
  local _shamt="0"

  print_R_encoding $_name $_rs $_rt $_rd $_shamt
  [[ ${EXECUTE_INSTRUCTIONS} == "TRUE" ]] || return

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
           _rt_text="$(printf "~ %0x%X" $(rval $_rt) )"
         ;;

      *) unset_cin
         ;;
  esac

  local _rs_value=$(rval $_rs)
  local _rt_value=${_rt_prefix}$(rval $_rt)
  LATCH_A=( "$_rs" "$_rs_value" )
  LATCH_B=( "${_rt_prefix}$_rt" "$_rt_value" )  # "$_rt_text") 

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

  alu_assign "$_rd" "$_value" "$_rs_value" "$_rt_value"
  print_ALU_state "$_op" $_rd
  unset_cin
}

function execute_ArithLogI () {
  local _name="$1"
  local _op="$2"
  local _rt="${3%,}"
  local _rs="${4%,}"
  local _text="$5"
  local _imm=$(parse_immediate "$_text")
  local _value

  print_I_encoding $_name $_rs $_rt $_imm
  [[ ${EXECUTE_INSTRUCTIONS} == "TRUE" ]] || return

  if [[ $_op == "+" ]] ; then 
    reset_cin
  fi

  local _rs_value=$(rval $_rs)

  case $_name in 
    addi* | slti* )
         _imm=$(sign_extension "$_imm")
         ;;
    andi* | ori* | xori* )
         imm=$(zero_extentsion "$_imm")
         ;;
  esac

  LATCH_A=( $_rs $_rs_value )
  LATCH_B=( imm ${_imm} "$_text" )

  _value=$(( _rs_value $_op _imm ))

  alu_assign "$_rt" "$_value" "$_rs_value" "$_imm"
  print_ALU_state "$_op" "$_rt"
  unset_cin
}

function execute_Shift () {
  # Effectively the syntax of a ArithLogI
  # but with a R format
  local _name="$1"
  local _op="$2"
  local _func_op="${_op/>>>/>>}"
  local _rd="${3%,}"
  local _rt="${4%,}"
  local _text="$5"
  local _shamt=$(parse_shamt "$_text")
  local _value

  print_R_encoding $_name "0" $_rt $_rd $_shamt
  [[ ${EXECUTE_INSTRUCTIONS} == "TRUE" ]] || return

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

  alu_assign "$_rd" "$_value" "$_rt_value" "$_shamt" 
  print_ALU_state "$_op" $_rd
}

function execute_ShiftV () {
  local _name="$1"
  local _op="$2"
  local _func_op="$(sed -e 's/>>>/>>/' <<< $_op)"
  local _rd="${3%,}"
  local _rt="${4%,}"
  local _rs="${5}"

  print_R_encoding $_name "$_rs" $_rt $_rd "0"
  [[ ${EXECUTE_INSTRUCTIONS} == "TRUE" ]] || return

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

  alu_assign "$_rd" "$_value" "$_rt_value" "$_rs_value" 
  print_ALU_state "$_op" $_rd
}


function execute_MoveTo ()  {
	# Example: mthi move _hi
  local _name="$1"
  local _op="$2"
  local _rd="$3"
  local _rs="$4"

  case $_name in
     mt*)  print_R_encoding $_name $_rs "0" "0" "0"
           ;;
     mf*)  print_R_encoding $_name "0" "0" $_rd "0"
           ;;
  esac

  [[ ${EXECUTE_INSTRUCTIONS} == "TRUE" ]] || return

  LATCH_A=($_rs $(rval $_rs) )
  LATCH_B=()

  assign "$_rd" "$(rval $_rs)"
  print_ALU_state "$_op" $_rd
}

function execute_MoveFrom() {
  execute_MoveTo $1 $2 $4 $3
}

function execute_DivMult () {
  local _name="$1"
  local _op="$2"
  local _rs="${3%,}"
  local _rt="$4"

  print_R_encoding $_name $_rs $_rt "0" "0"
  [[ ${EXECUTE_INSTRUCTIONS} == "TRUE" ]] || return


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
  #    llo $t1,              0xAAAA AAAA
  #    lhi $t1, 0xFFFF FFFF 
  #  llo:  LH ($t) = i
  #  lhi:  HH ($t) = i
  #  implicit "|" is performed

  local _name="$1"
  local _op="$2"
  local _rt="${3%,}"
  local _text="$4"
  local _imm=$(parse_immediate "$_text")

  local _op="|"
  local _value
  local _rt_name="$(name $_rt)"
  local _rt_value="$(rval $_rt)"

  print_I_encoding $_name $zero $_rt $_imm
  [[ ${EXECUTE_INSTRUCTIONS} == "TRUE" ]] || return

  case $_name in 
    lui)
         (( _value= $_imm << 16 ))
         _text="$_text << 16"
         LATCH_A=(  )
         _op="="
         ;;

    lhi)
         (( _rt_value =  _rt_value &  0x0000FFFF ))
         (( _value = $_imm << 16 ))
         _text="$_text << 16"
         LATCH_A=( "HH(${_rt_name})" $_rt_value "${_rt_name} & 0x0000FFFF")
         ;;

    llo)
         (( _rt_value =  _rt_value &  0xFFFF0000 ))
         (( _value= _imm & 0x0000FFFF ))
         _text="$_text"
         LATCH_A=( "LH(${_rt_name})" $_rt_value "${_rt_name} & 0xFFFF0000" )
         ;;
  esac
  LATCH_B=( imm "${_value}" "$_text" )

  alu_assign "$_rt" "$(( _rt_value $_op _value ))" "0"
  print_ALU_state "$_op" $_rt
}

function execute_Branch () {
  local _name="$1"
  local _op="$2"
  local _rs="${3%,}"
  local _rt="${4%,}"
  local _label="$5"
  
  local _imm=$(encode_offset $_label)

  ## Print the Encoding
  {
    print_I_encoding $_name $_rs $_rt $_imm $_label

    emit_p=${EMIT_ENCODINGS}
    EMIT_ENCODINGS=FALSE

    execute_ArithLog "sub" "-" $zero $_rs $_rt
    EMIT_ENCODINGS=$emit_p

  }
  [[ ${EXECUTE_INSTRUCTIONS} == "TRUE" ]] || return

  local _next=$(rval $_npc)
  local _addr=$(lookup_text_label $_label)
  local _resolved=$_addr
  if [[ -z "$_addr" ]] ; then
    _resolved=$_label   # the label is unresolved
  fi

  case "$_name" in 
    beq) if [[ ${STATUS_BITS[$_z_bit]} == "1" ]] ; then
           assign $_npc $_resolved
         else
           :
         fi
         ;;
    bne) if [[ ${STATUS_BITS[$_z_bit]} == "0" ]] ; then
           assign $_npc $_resolved
         else
           :
         fi
         ;;
  esac
  print_NPCWB_stage "${STATUS_BITS[$_z_bit]}" "$_next" "$_addr" "$_label"

}


function execute_BranchZ () {
  local _name="$1"
  local _op="$2"
  local _rs="${3%,}"
  local _label="$4"

  ## Print the Encoding
  {
    print_I_encoding $_name $_rs $_rt $_imm $_label

    emit_p=${EMIT_ENCODINGS}
    EMIT_ENCODINGS=FALSE

    # I could also also execute an any instruction that results in the ALU output
    # beign the same as $_rs
    execute_ArithLog "sub" "-" $_zero $_rs $_zero 
    EMIT_ENCODINGS=$emit_p
  }
  [[ ${EXECUTE_INSTRUCTIONS} == "TRUE" ]] || return

  local _next=$(rval $_npc)
  local _addr=$(lookup_text_label $_label)
  local _resolved=$_addr
  if [[ -z "$_addr" ]] ; then
    _resolved=$_label   # the label is unresolved
  fi

  case "$_name" in 
    bgtz) if [[ ${STATUS_BITS[$_s_bit]} == 0 && ${STATUS_BITS[$_z_bit]} == 0 ]] ; then 
             # result is positive, hence '$_rs > 0'
             assign $_npc $_resolved
          else
            :
          fi
          ;;
    blez) if [[ ${STATUS_BITS[$_s_bit]} == 1 || ${STATUS_BITS[$_z_bit]} == 1 ]] ; then 
             # result is positive, hence '$_rs <= 0'
             assign $_npc $_resolved
          else
            :
          fi
          ;;
  esac

  print_NPCWB_stage "${STATUS_BITS[$_z_bit]}" "$_next"  "$_addr" "$_label"

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
  local _rt="${3%,}"
  local _rs="${4%,}"
  local _text="$5"
  local _imm=$(parse_immediate "$_text")
  local _value

  ## Print the Encoding
  { 
    print_I_encoding $_name $_rs $_rt $_imm

    emit_p=${EMIT_ENCODINGS}
    EMIT_ENCODINGS=FALSE

    execute_ArithLogI "addi" "+" $_mar $_rs $_imm $_text
    EMIT_ENCODINGS=$emit_p
  }
  [[ ${EXECUTE_INSTRUCTIONS} == "TRUE" ]] || return


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

          alu_assign "$_rt" "$_rt_value" "0"  # Operation is being run through the ALU
          ;;
      s*)
          _rt_value=$(rval $_rt)

          alu_assign "$_mbr" "$_rt_value" "0"
          data_memory_write $_size
          ;;
   esac
   print_WB_stage "$_name" "$_rt" "$_size"

}


function execute_Jump () {
  # Usage:  name -- _label
  local _name="$1"
  local _op="$2"
  local _label="$3"

  print_J_encoding $_name $_label
  [[ ${EXECUTE_INSTRUCTIONS} == "TRUE" ]] || return

  local _next=$(rval $_npc)
  local _addr=$(lookup_text_label $_label)
  local _resolved=$_addr
  if [[ -z "$_addr" ]] ; then
    _resolved=$_label   # the label is unresolved
  fi

  case $_name in 
    jal) 
         LATCH_A=( $_npc )
         LATCH_B=( $zero )
         alu_assign "$ra" "$(( $(rval $_npc) ))" "0"
         print_ALU_state "|" "$ra"
         ;;
  esac
  assign $_npc $_resolved
  print_NPCWB_stage "1" "$_next" "$_addr" "$_label"

}



function execute_JumpR () {
  # Usage:  name -- rs   # R-format
  local _name="$1"
  local _op="$2"
  local _rs="$3"

  ## encode_R_instruction $_name $_rs "0" "0" "0"
  ## print_R_encoding $_name $_rs "0" "0" "0"
  [[ ${EXECUTE_INSTRUCTIONS} == "TRUE" ]] || return

  local _next=$(rval $_npc)
  local _addr=$(lookup_text_label $_label)
  local _resolved=$_addr
  if [[ -z "$_addr" ]] ; then
    _resolved=$_label   # the label is unresolved
  fi

  case $_name in 
    jalr) 
         LATCH_A=( $_npc )
         LATCH_B=( $zero )
         alu_assign "$ra" "$(( $(rval $_npc) ))" "0"
         print_ALU_state "|" $ra
         ;;
  esac

  assign $_npc $_resolved
  print_NPCWB_stage "1" "$_next" "$_addr" "$_label"

}
