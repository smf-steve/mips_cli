#! /bin/bash

source libexec/machine/registers.bash
source libexec/machine/encodings.bash
source libexec/machine/memory.bash

declare -a LATCH_A=()   # whence registers, value
declare -a LATCH_B=()   # whence register/imm, value, text

declare -i cin 
 alias unset_cin="cin=-1"     # unset to prevent printing
 alias set_cin="cin=1"        # set to 1 for subraction
 alias reset_cin="cin=0"      # set to 0 for addition
 unset_cin

declare -r _c_bit=0 ;  STATUS_BITS[$_c_bit]="0" 
declare -r _v_bit=1 ;  STATUS_BITS[$_v_bit]="0" 
declare -r _s_bit=2 ;  STATUS_BITS[$_s_bit]="0" 
declare -r _z_bit=3 ;  STATUS_BITS[$_z_bit]="0" 

function reset_status_bits() {
  STATUS_BITS[$_c_bit]=0
  STATUS_BITS[$_v_bit]=0
  STATUS_BITS[$_s_bit]=0
  STATUS_BITS[$_z_bit]=0
}
function assign_status_bits() {
  local _value="$1"
  local _rs_value="$2"
  local _rt_value="$3"

  local _both_pos=$(( _rs_value >= 0 && _rt_value >= 0 ))
  local _both_neg=$(( _rs_value <  0 && _rt_value  < 0 ))
  local flipped_to_neg=$(( _value < 0 && _both_pos ))
  local flipped_to_pos=$(( _value > 0 && _both_neg ))

  STATUS_BITS[$_v_bit]=$(( flipped_to_neg | flipped_to_pos ))
  STATUS_BITS[$_c_bit]=$(( _value > max_word_unsigned ? 1 : 0))
  STATUS_BITS[$_s_bit]=$(( _value < 0 ))
  STATUS_BITS[$_z_bit]=$(( _value == 0 ))
}

function print_status_bits() {
  printf "\tC: %c;\tV: %c;\tS: %c;\tZ: %c\n\n" \
      ${STATUS_BITS[$_c_bit]} \
      ${STATUS_BITS[$_v_bit]} \
      ${STATUS_BITS[$_s_bit]} \
      ${STATUS_BITS[$_z_bit]}

}


alias trap_on_C=":"
alias trap_on_V=":"
alias trap_on_S=":"
alias trap_on_Z=":"


function print_ALU_state() {
  # Print values on the two input latches with the op and output register/s
  local _op="$1"
  local _dst1="$2"
  local _dst2="$3"

  [[ "${EMIT_EXECUTION_SUMMARY}" == "TRUE" ]] || return

  print_cin $cin
  [[ $LATCH_A != "" ]]  &&  print_value "${LATCH_A[@]}"
  [[ $LATCH_B != "" ]]  &&  print_value "${LATCH_B[@]}"

  print_op "$_op"

  print_value $_dst1
  [[ $_dst2 != "" ]]  && print_value $_dst2
  echo 
  print_status_bits
}

function print_immediate() {
  local _text="$1"
  local _value=$(parse_immediate "$_text")

  print_value imm $_value "$_text"
}


# the value in the register is a string, which is one of the following
# -5
# ~5
# X where X=$(( 0xFF FF FF FB ))
#
# output: 
#   simple: -5, or ~5 in the text area
#   signed: $(signed_extention $(( value )) )
#   unsigned:  $(signed_contraction $((value )) )

function print_value() {
  # if the input is one value, 
  #   then print it as a register
  #   otherwise print as an immediate
  local _register="$1"
  local _value="$2"
  local _text="$3"
  local _name
  local _rval
  local _prefix

  _prefix=${_register:0:1}
  if [[ $_prefix == '~' ]] ; then
   _register=${_register:1}
  else
   _prefix=""
  fi

  case ${#} in
      1) # print the current contents of the register
         _name=${_prefix}$(name ${_register})
         _rval=$((${_prefix}$(rval ${_register}) ))
         ;;
      2) # print the old value of the register
         _name=${_prefix}$(name ${_register})
         _rval=$((${_prefix}${_value} ))
         ;;
      3) # print the value as an immediate
         _name="$_register"    
         _rval=$(( ${_prefix}${_value} ))
         ;;
  esac

  if [[ -z "$_text" ]] ; then
    _prefix=${_rval:0:1}
  fi
  if [[ $_prefix == '~' || $_prefix == '-' ]] ; then
   _text=
   _register=${_register:1}

  else
   _prefix=""
  fi

  print_value_i "$_name" "$_rval" "$_text"
}

function print_value_i () {
  local _name="$1"
  local _rval="$2"
  local _text="$3"

  if [[ -z "$_rval" ]] ; then 
    # its a deferred value
    local _dec="?"
    local _unsigned="?"
    local _hex="?? ?? ?? ??"
    local _bin="???? ???? ???? ???? ???? ???? ???? ????"
  else
    local _dec=${_rval}
    local _unsigned=$(( _rval & 0xFFFFFFFF ))
    local _hex=$(to_hex 8 $_unsigned )
    local _bin=$(to_binary "${_hex}")
  fi
  printf "   %6s:  %11s %11s; 0x%s; 0b%s;"  \
        "${_name}" "${_dec}" "${_unsigned}" "${_hex}" "${_bin}"

  if [[ "$_text" != "" ]] ; then
    printf " \"%s\"" "${_text}"
  fi
  printf "\n"
}


function print_op() {
   local _op="$1"
      
   printf "   %9s  --------  ----------- -------------- ------------------------------------------\n" \
          "${_op}"      
}


function print_cin() {
   [[ $cin == -1 ]]  && return

   printf "     %5s         %4s        %4s;             %c;                                          %c;\n" \
             "cin:" "${cin}" "${cin}" "${cin}" "${cin}"
}

function print_Z() {
   local value=${STATUS_BITS[$_z_bit]}

   printf "     %5s         %4s        %4s;             %c;                                         %c;\n" \
             "Z  :" "${value}" "${value}" "${value}" "${value}"
}


#Maybe rename to:
# print_mem_WB_stage
# print_pc_WB_stage  


function print_NPCWB_stage () {
  local z_bit="$1"
  local _current="$2"
  local _addr="$3"
  local _label="$4"

  [[ "${EMIT_EXECUTION_SUMMARY}" == "TRUE" ]] || return

  print_value_i "#0" "$_current" "npc"
  print_value_i "#1" "$_addr" "$_label"
  print_op "mux (Z=${z_bit})"
  print_value   "$_npc"  
}


#      #0:           0           0; 0x00 00 00 00; 0b0000 0000 0000 0000 0000 0000 0000 0000; "pc"
#      #1:           5           5; 0x00 00 00 05; 0b0000 0000 0000 0000 0000 0000 0000 0101; "_address"
#      Z:            0           0;             0;                                         0;
#       mux ----------  ----------- -------------- ------------------------------------------
#     npc:           5           5; 0x00 00 00 05; 0b0000 0000 0000 0000 0000 0000 0000 0101;



alias print_WB_stage="print_MEMWB_stage"
function print_MEMWB_stage() {
  # The WB stage is responsible for 
  #   1. summarizing the operation that was perfromed via a load store
  #      -- print the values in the last two latches
  #   1. summaryizig the operation that was performed via a jal and jalr operation
  #      - print the values of the old pc --> $ra


  # Print values on the two input latches with the op and output register/s

  local _name="$1"
  local _register="$2"
  local _size="$3"


  [[ "${EMIT_EXECUTION_SUMMARY}" == "TRUE" ]] || return
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

  printf "   %6s:  %11d %11d; 0x%11s; 0b%39s;"  \
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



