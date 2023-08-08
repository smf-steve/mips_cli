#! /bin/bash

source ${MIPS_CLI_HOME}/libexec/machine/constants.bash
source ${MIPS_CLI_HOME}/libexec/machine/registers.bash
source ${MIPS_CLI_HOME}/libexec/machine/codes.bash
source ${MIPS_CLI_HOME}/libexec/machine/memory.bash

#################################################################################
#
#
# Functions:
#   1. Trap support:
#      - reset_trap_on             
#      - trap_on_status_bits
#   1. Status bits
#      - reset_status_bits             
#      - print_status_bits 
#   1. ALU update
#      - alu_update:  based upon the values of LATCH A and B, updates the state of the ALU
#      - alu_assign            
#      - print_ALU_state  
#      -   print_cin 
#      -   print_op  
#   1. Print a line for a particular value/register, etc.
#        * E.G.: 
#           t1:   -559038737  3735928559; 0xde ad be ef; 0b1101 1110 1010 1101 1011 1110 1110 1111;
#      - print_value     reg value text           
#      - print_value_i   name value text         # Perhaps fold into ..print_value
#      - print_immediate value            
#      - print_Z                                 # Most likely defunct  


# print_NPC_WB_stage               
# print_MEM_WB_stage             
# print_WB_value               



declare -a LATCH_A=()   # whence registers, value
declare -a LATCH_B=()   # whence register/imm, value, text

declare -i CIN 
  alias unset_cin="CIN=-1"     # unset to prevent printing
  alias   set_cin="CIN=1"      # set to 1 for subraction
  alias reset_cin="CIN=0"      # set to 0 for addition
  unset_cin

declare -r _c_bit=0 ;  STATUS_BITS[$_c_bit]="0" 
declare -r _v_bit=1 ;  STATUS_BITS[$_v_bit]="0" 
declare -r _s_bit=2 ;  STATUS_BITS[$_s_bit]="0" 
declare -r _z_bit=3 ;  STATUS_BITS[$_z_bit]="0" 


function reset_trap_on() {
  trap_C="FALSE"
  trap_V="FALSE"
  trap_S="FALSE"
  trap_V="FALSE"
}

alias trap_on_C="trap_C=TRUE"
alias trap_on_V="trap_V=TRUE"
alias trap_on_S="trap_S=TRUE"
alias trap_on_Z="trap_Z=TRUE"

alias C_trap=":"
alias S_trap=":"
alias Z_trap=":"
function V_trap () {
  if [[ "${trap_V}" == "TRUE" ]] ; then 
    # trap 12
    echo "Trap due to overflow"
  fi
}

function reset_status_bits() {
  STATUS_BITS[$_c_bit]=0
  STATUS_BITS[$_v_bit]=0
  STATUS_BITS[$_s_bit]=0
  STATUS_BITS[$_z_bit]=0
}


function print_status_bits() {
  printf "\tC: %c;\tV: %c;\tS: %c;\tZ: %c\n\n" \
      ${STATUS_BITS[$_c_bit]} \
      ${STATUS_BITS[$_v_bit]} \
      ${STATUS_BITS[$_s_bit]} \
      ${STATUS_BITS[$_z_bit]}
}

function trap_on_status_bits () {
  # If a trap_on_<bit> is set, echo out a message
  [[ ${STATUS_BITS[$_c_bit]} == "1" ]]  && C_trap
  [[ ${STATUS_BITS[$_v_bit]} == "1" ]]  && V_trap
  [[ ${STATUS_BITS[$_s_bit]} == "1" ]]  && S_trap
  [[ ${STATUS_BITS[$_z_bit]} == "1" ]]  && Z_trap
  reset_trap_on
}





function print_ALU_state() {
  # Print values on the two input latches with the op and output register/s
  local _op="$1"
  local _dst1="$2"
  local _dst2="$3"

  [[ "${EMIT_EXECUTION_SUMMARY}" == "TRUE" ]] || return

  print_cin $CIN $(rval $_dst1) 
  [[ "$LATCH_A" != "" ]]  &&  print_value "${LATCH_A[@]}"
  [[ "$LATCH_B" != "" ]]  &&  print_value "${LATCH_B[@]}"

  print_op "$_op"

  print_value $_dst1
  [[ "$_dst2" != "" ]]  && print_value $_dst2

  echo 
  print_status_bits
  trap_on_status_bits
  echo
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
         _rval=$(( $(rval ${_register}) ))
         ;;
      2) # print the old value of the register
         _name=${_prefix}$(name ${_register})
         _rval=$(( ${_value} ))
         ;;
      3) # print as is since _text_ was provided
         _name="$_register"    
         _rval=$(( ${_value} ))
         ;;
  esac

  # What does the following -- before the print_value_i do?
  # if [[ -z "$_text" ]] ; then
  #   _prefix=${_rval:0:1}
  # fi
  # if [[ $_prefix == '~' || $_prefix == '-' ]] ; then
  #   _text=        #  "~ 0x$(to_hex 8 $(rval $_register))"
  #   _register=${_register:1}

  # else
  #   _prefix=""
  # fi
  if [[ -z "$_text" && ${_value:0:1} == "~"  ]] ; then
    _text=$_value
  fi
  print_value_i "$_name" "$_rval" "$_text"
}

function print_value_i () {
  local _name="$1"
  local _rval="$2"
  local _text="$3"

  if [[ -z "$_rval" ]] ; then 
    # its an _unresolved_ value
    local _dec="?"
    local _unsigned="?"
    local _hex="????????"
    local _bin="????????????????????????????????"
  else
    local _dec=${_rval}
    local _unsigned=$(( _rval & 0xFFFFFFFF ))
    local _hex=$(base16_digits 8 $_unsigned )
    local _bin=$(base2_digits 32 $_unsigned )
  fi
  printf "   %6s:  %11s %11s; 0x%s; 0b%s;"  \
        "${_name}" "${_dec}" "${_unsigned}" "$(group_4_2 ${_hex})" "$(group_8_4 ${_bin})"

  if [[ "$_text" != "" ]] ; then
    printf " \"%s\"" "${_text}"
  fi
  printf "\n"
}


function print_immediate() {
  local _text="$1"
  local _value=$(parse_immediate "$_text")

  print_value imm $_value "$_text"
}


function print_op() {
   local _op="$1"
      
   printf "   %9s   --------  ----------- -------------- ------------------------------------------\n" \
          "${_op}"      
}


function print_cin() {
   local cin="$1"
   local result="$(( $2 & 0xFFFFFFFF ))"

   local src1="$(( LATCH_A[1] & 0xFFFFFFFF ))"
   local src2="$(( LATCH_B[1] & 0xFFFFFFFF ))"

   local carry_row="$(( result ^ src1 ^ src2 ))"

   local _hex=$(base16_digits 8 ${carry_row} )
   local _bin=$(base2_digits 32 ${carry_row} )

   [[ $cin == -1 ]]  && return

   printf "     %5s  %11s %11s; %13s;   %s; \"%s\"\n" \
             "cin:" "${cin}" "${cin}" "${cin}" "$(group_8_4 ${_bin})" "cin=${cin}"
}

function print_Z() {
   local value=${STATUS_BITS[$_z_bit]}

   printf "     %5s         %4s        %4s;             %c;                                        %c;\n" \
             "Z  :" "${value}" "${value}" "${value}" "${value}"
}



function alu_update () {
  # In the future the input should be a function that applies extra values with 
  # the value LATCH_A and LATCH_B to obtain the final value
  # local func="$1" ; shift
  # local args="$@"
  # $fun $LATCH_A $LATCH_C $args

  # Compute the status bits, based upon the original input values...
  # Force the input parameters to be only 32-bit numbers.
  # Negative numbers would have 1 values in bits 32-63
  local _src1="$(( ${LATCH_A[1]:-0} & 0xFFFFFFFF ))"
  local _src2="$(( ${LATCH_B[1]:-0} & 0xFFFFFFFF ))"

  # Make adjustments to _value to represent a 32-bit quantity using 64 bits.  
  local _value_32=$(( _value & 0xFFFFFFFF ))   # This final 32-bit number
  local _carry_row=$(( _value_32 ^ _src1 ^ _src2))

  local _carry_out=$(( ( (_src1 + _src2 ) & 0x1FFFFFFFF ) >> 32 ))
  local _carry_in=$(( _carry_row >> 31))

  local _sign_bit=$(( _value_32 >> 31 ))
  local _zero_bit=$(( _value_32 == 0 ))
  local _overflow_bit=$((  _carry_out ^ _carry_in ))

  #assign_status_bits "$_value_32" "$_src1" "$_src2"
  STATUS_BITS[$_s_bit]=$_sign_bit
  STATUS_BITS[$_c_bit]=$_carry_out
  STATUS_BITS[$_v_bit]=$_overflow_bit
  STATUS_BITS[$_z_bit]=$_zero_bit
}

# Perhaps alu_assign, should be rename ALU_WB, etc.
function alu_assign() {
  local _index="$1"
  local _value="$2"

  alu_update
  trap_on_status_bits
  assign $_index $_value
}



function print_NPC_WB_stage () {
  local z_bit="$1"
  local _current="$2"
  local _addr="$3"
  local _label="$4"

  [[ "${EMIT_EXECUTION_SUMMARY}" == "TRUE" ]] || return

  print_value_i "#0" "$_current" "npc"
  print_value_i "#1" "$_addr" "$_label"
  print_op "mux (Z=${z_bit})"

  # Now handle the special case where the address in NPC is an unresolved reference
  local _next=$(rval $_npc)
  if [[ ${_next:0:1} =~ [[:alpha:]]   ]] ; then 
    print_value_i "npc" "" "$_next"
  else
    print_value_i "npc" "$_next"  
  fi
  echo
}


#      #0:           0           0; 0x00 00 00 00; 0b0000 0000 0000 0000 0000 0000 0000 0000; "pc"
#      #1:           5           5; 0x00 00 00 05; 0b0000 0000 0000 0000 0000 0000 0000 0101; "_address"
#      Z:            0           0;             0;                                         0;
#       mux ----------  ----------- -------------- ------------------------------------------
#     npc:           5           5; 0x00 00 00 05; 0b0000 0000 0000 0000 0000 0000 0000 0101;



function print_MEM_WB_stage() {
  # The WB stage is responsible for 
  #   1. summarizing the operation that was perfromed via a load store
  #      -- print the values in the last two latches
  #   1. summaryizig the operation that was performed via a jal and jalr operation
  #      - print the values of the old pc --> $ra


  # Print values on the two input latches with the op and output register/s

  local _name="$1"
  local _register="$2"
  local _size="$3"      # number of bytes


  [[ "${EMIT_EXECUTION_SUMMARY}" == "TRUE" ]] || return
  case "$_name" in
    l*)
       print_WB_value "$(name $_mbr)" $(rval $_mbr) $_size
       print_op "$_name"
       print_WB_value "$(name $_register)" $(rval $_register)  4
       ;;
    s*)
       print_WB_value "$(name $_register)" $(rval $_register)  4
       print_op "$_name"
       print_WB_value "$(name $_mbr)" $(rval $_mbr) $_size
       ;;
  esac
  echo 
}

function print_WB_value () {
  local _name="$1"
  local _rval="$2"
  local _size="$3"   ;  [[ $_size == "" ]] && _size=4    # Number of bytes transferred

  local _dec=${_rval}
  local _unsigned=$(( _rval & 0xFFFFFFFF ))
      # If this is a negative number, then we need to trancate the digits so that the size works out

  local _truncated
  case $_size in 
    1) _truncated=$(( _unsigned & 0xFF )) ;;
    2) _truncated=$(( _unsigned & 0xFFFF )) ;;
    4) _truncated=$(( _unsigned & 0xFFFFFF )) ;;
  esac

  local _hex=$(base16_digits $(( _size * 2 )) ${_truncated} )
  local _bin=$(base2_digits $(( _size * 8 )) "${_truncated}" )   

  printf "   %6s:  %11d %11d; 0x%11s; 0b%39s;"  \
        "${_name}" "${_dec}" "${_unsigned}" "$(group_2 ${_hex})" "$(group_4 ${_bin})"
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


