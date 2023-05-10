#! /bin/bash

# CONSTANTS
min_shamt=0
max_shamt=$(( 2 ** 5 ))

max_immediate_unsigned=$(( 2 ** 16 ))
min_immediate=$(( - 2 ** 15  ))
max_immediate=$( - min_immediate - 1 )

max_word_unsigned=$(( 2 * 32 ))
min_word=$(( - 2 ** 31  ))
max_word=$(( - min_word - 1 ))

max_dword_unsigned=$(( 2 * 64 ))
min_dword=$(( - 2 ** 63 ))
max_dword=$(( - max_dword -1  ))


# REGISTERS
                      declare -a NAME ; declare -a REGISTER

declare -r zero='0' ; NAME[$zero]="zero" ; REGISTER[$zero]="0"
declare -r at='1'   ; NAME[$at]="at"     ; REGISTER[1]="0"
declare -r v0='2'   ; NAME[$v0]="v0"     ; REGISTER[2]="0"
declare -r v1='3'   ; NAME[$v1]="v1"     ; REGISTER[3]="0"
declare -r a0='4'   ; NAME[$a0]="a0"     ; REGISTER[4]="0"
declare -r a1='5'   ; NAME[$a1]="a1"     ; REGISTER[5]="0"
declare -r a2='6'   ; NAME[$a2]="a2"     ; REGISTER[6]="0"
declare -r a3='7'   ; NAME[$a3]="a3"     ; REGISTER[7]="0"
declare -r t0='8'   ; NAME[$t0]="t0"     ; REGISTER[8]="0"
declare -r t1='9'   ; NAME[$t1]="t1"     ; REGISTER[9]="0"
declare -r t2='10'  ; NAME[$t2]="t2"     ; REGISTER[10]="0"
declare -r t3='11'  ; NAME[$t3]="t3"     ; REGISTER[11]="0"
declare -r t4='12'  ; NAME[$t4]="t4"     ; REGISTER[12]="0"
declare -r t5='13'  ; NAME[$t5]="t5"     ; REGISTER[13]="0"
declare -r t6='14'  ; NAME[$t6]="t6"     ; REGISTER[14]="0"
declare -r t7='15'  ; NAME[$t7]="t7"     ; REGISTER[15]="0"
declare -r s0='16'  ; NAME[$s0]="s0"     ; REGISTER[16]="0"
declare -r s1='17'  ; NAME[$s1]="s1"     ; REGISTER[17]="0"
declare -r s2='18'  ; NAME[$s2]="s2"     ; REGISTER[18]="0"
declare -r s3='19'  ; NAME[$s3]="s3"     ; REGISTER[19]="0"
declare -r s4='20'  ; NAME[$s4]="s4"     ; REGISTER[20]="0"
declare -r s5='21'  ; NAME[$s5]="s5"     ; REGISTER[21]="0"
declare -r s6='22'  ; NAME[$s6]="s6"     ; REGISTER[22]="0"
declare -r s7='23'  ; NAME[$s7]="s7"     ; REGISTER[23]="0"
declare -r t8='24'  ; NAME[$t8]="t8"     ; REGISTER[24]="0"
declare -r t9='25'  ; NAME[$t9]="t9"     ; REGISTER[25]="0"
declare -r k0='26'  ; NAME[$k0]="k0"     ; REGISTER[26]="0"
declare -r k1='27'  ; NAME[$k1]="k1"     ; REGISTER[27]="0"
declare -r gp='28'  ; NAME[$gp]="gp"     ; REGISTER[28]="0"
declare -r sp='29'  ; NAME[$sp]="sp"     ; REGISTER[29]="0"
declare -r fp='30'  ; NAME[$fp]="fp"     ; REGISTER[30]="0"
declare -r ra='31'  ; NAME[$ra]="ra"     ; REGISTER[31]="0"
declare -r _pc='32' ; NAME[$_pc]="pc"    ; REGISTER[32]="0"
declare -r _hi='33' ; NAME[$_hi]="hi"    ; REGISTER[33]="0"
declare -r _lo='34' ; NAME[$_lo]="lo"    ; REGISTER[34]="0"

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
  local _index=$(sed -e 's/,$//' <<< "$1" )
  local _value="$2"
  local _high_order=$(( (_value >> 32) & 0xFFFFFFFF ))
     # shift right, and then get rid of the high-order bits

  # Here the number must be in the appropriate range.
  if (( $_high_order != 0x00000000 && $_high_order != 0xFFFFFFFF   )) ; then
      echo "Error: Assignment value requires more than 32 bits"
  fi
  [[ $1 == 0 ]] ||  REGISTER[$_index]="$_value"
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

function set_registers () {
  local _value

  if [[ $# == 0 ]] ; then
     set_registers_random
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
function set_registers_random () {
  assign $zero "0";  
  for ((i=1; i<32; i++)) ; do
   assign $i "$(random_value)"
  done
  # assign $_pc "0"
  assign $_hi "$(random_value)"
  assign $_lo "$(random_value)"
}

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

  print_cin $cin
  print_value "${LATCH_A[@]}"
  [[ $LATCH_B != "" ]]  &&  print_value "${LATCH_B[@]}"

  print_op "$_op"

  print_value $_dst1
  [[ $_dst2 != "" ]]  && print_value $_dst2
  echo 
}

alias print_register="print_value"
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
   _text=$omething
   _register=${_register:1}

  else
   _prefix=""
  fi


   _dec=${_rval}
   _hex=$(to_hex 8 $(sign_contraction $_rval ))
   _bin=$(to_binary "${_hex}")

   printf "   %5s:  %d %u %11s; 0x%s; 0b%s;"  \
         "${_name}" "${_dec}" "${_dec}" "${_dec}" "${_hex}" "${_bin}"

   if [[ "$_text" != "" ]] ; then
     printf " \"%s\"" "${_text}"
   fi
   printf "\n"
}


#(mips) printf "%d, %u\n" -2 -2
#-2, 18446744073709551614


function print_op () {
   local _op="$1"
      
   printf "     %3s  %-4s ----------- -------------- ------------------------------------------\n" \
          "" "${_op}"      
}


function print_cin() {
   
   if [[ $cin != -1 ]] ; then 

      printf "     %4s                %c               %c                                         %c;\n" \
             "cin:" "${cin}" "${cin}" "${cin}"
   fi
}

