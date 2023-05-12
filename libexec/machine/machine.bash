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
function assign_status_bits () {
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


function name() {
  local _index=$(sed -e 's/,$//' <<< "$1" )
  echo ${NAME[$_index]}
}
function rval() {
  local _index=$(sed -e 's/,$//' <<< "$1" )
  echo ${REGISTER[$_index]}
}



function assign() {
  # The value computed is 

  # Place a number that can be represented as a 
  #   32-bit value into a register.
  # Recall that the shell has 64 bits.

  local _index="$1"
  local _value="$2"
  local _src1="$3"
  local _src2="$4"

  if (( _value > max_word )) ; then
    # we need to extend the sign for a 64-bit value
    _value=$(( _value | 0xFFFFFFFF00000000 ))
  fi

  assign_status_bits $_value $_rs_value $_rt_value
  REGISTER[$_index]="$_value"
}

function reset_registers () {
  assign $zero "0"  
  for ((i=1; i<32; i++)) ; do
   assign $i "0"
  done
  # assign $_pc "0"
  assign $_hi "0"
  assign $_lo "0" 
}

function assign_registers () {
  local _value

  if [[ $# == 0 ]] ; then
     assign_registers_random
     return
  fi

  _value=$(read_word "$1")

  assign $zero "0";  
  for ((i=1; i<32; i++)) ; do
    assign $i "$_value"
  done
  # assign $_pc "0"
  assign $_hi "$_value"
  assign $_lo "$_value"
}
function random_value () {
  echo $(( $RANDOM % 0xF + 1))
}
function assign_registers_random () {
  assign $zero "0";  
  for ((i=1; i<32; i++)) ; do
   assign $i "$(random_value)"
  done
  # assign $_pc "0"
  assign $_hi "$(random_value)"
  assign $_lo "$(random_value)"
}

alias print_register="print_value"
function print_registers () {

  for ((i=0; i<32; i++)) ; do
    print_register $i
  done
  echo
  print_register $_pc
  print_register $_hi
  print_register $_lo

}

function print_ALU_state () {
  # Print values on the two input latches with the op and output register/s
  local _op="$1"
  local _dst1="$2"
  _dst2="$3"

  [[ $emit_execution_summary == "TRUE" ]] || return

  print_cin $cin
  print_value "${LATCH_A[@]}"
  [[ $LATCH_B != "" ]]  &&  print_value "${LATCH_B[@]}"

  print_op "$_op"

  print_value $_dst1
  [[ $_dst2 != "" ]]  && print_value $_dst2
  echo 
  print_status_bits
}

function print_immediate () {
  local _text="$1"
  local _value=$(read_immediate "$_text")
  local _value=$(sign_extension $_value)
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

function print_value () {
  # if the input is one value, then print it as a register
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
         _name="imm"    
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


  local _dec=${_rval}
  local _unsigned=$(( _rval & 0xFFFFFFFF ))
  local _hex=$(to_hex 8 $_unsigned )
  local _bin=$(to_binary "${_hex}")

  printf "   %5s:  %11d %11d; 0x%s; 0b%s;"  \
        "${_name}" "${_dec}" "${_unsigned}" "${_hex}" "${_bin}"

  if [[ "$_text" != "" ]] ; then
    printf " \"%s\"" "${_text}"
  fi
  printf "\n"
}


function print_op () {
   local _op="$1"
      
   printf "       %4s ----------  ----------- -------------- ------------------------------------------\n" \
          "${_op}"      
}


function print_cin() {
   [[ $cin == -1 ]]  && return

   printf "     %4s         %4s        %4s;             %c;                                         %c;\n" \
             "cin:" "${cin}" "${cin}" "${cin}" "${cin}"
}

