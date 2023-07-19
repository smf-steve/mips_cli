#! /bin/bash


#################################################################################
# This file contains the functions required to that relate to registers
#
# List of functions:
#   name $t1 : prints the name of a register
#   rval $t1 : prints the rval/contents of a register
#   assign $t1 value : places a value into a register
#
alias reset_registers="assign_registers 0"
#   assign_registers value : all registers set to value
#   assign_registers       : all registers set to a random value (0.. 0xFFFF)
#   assign_registers_random max : all registers set to a rand value 0.. max)
#
alias print_register="print_value"
#   print_register $t1 :  prints a value in the registers
#   print_registers [ list ]  :  -- possible move to other file
# 
#   random_value : generates a random value (0.. 0xFFFF)
#
#################################################################################

# REGISTERS
                      declare -a NAME ; declare -a REGISTER

declare -r   zero='0' ; NAME[$zero]="0"    ; REGISTER[$zero]="0"
declare -r   at='1'   ; NAME[$at]="at"     ; REGISTER[1]="0"
declare -r   v0='2'   ; NAME[$v0]="v0"     ; REGISTER[2]="0"
declare -r   v1='3'   ; NAME[$v1]="v1"     ; REGISTER[3]="0"
declare -r   a0='4'   ; NAME[$a0]="a0"     ; REGISTER[4]="0"
declare -r   a1='5'   ; NAME[$a1]="a1"     ; REGISTER[5]="0"
declare -r   a2='6'   ; NAME[$a2]="a2"     ; REGISTER[6]="0"
declare -r   a3='7'   ; NAME[$a3]="a3"     ; REGISTER[7]="0"
declare -r   t0='8'   ; NAME[$t0]="t0"     ; REGISTER[8]="0"
declare -r   t1='9'   ; NAME[$t1]="t1"     ; REGISTER[9]="0"
declare -r   t2='10'  ; NAME[$t2]="t2"     ; REGISTER[10]="0"
declare -r   t3='11'  ; NAME[$t3]="t3"     ; REGISTER[11]="0"
declare -r   t4='12'  ; NAME[$t4]="t4"     ; REGISTER[12]="0"
declare -r   t5='13'  ; NAME[$t5]="t5"     ; REGISTER[13]="0"
declare -r   t6='14'  ; NAME[$t6]="t6"     ; REGISTER[14]="0"
declare -r   t7='15'  ; NAME[$t7]="t7"     ; REGISTER[15]="0"
declare -r   s0='16'  ; NAME[$s0]="s0"     ; REGISTER[16]="0"
declare -r   s1='17'  ; NAME[$s1]="s1"     ; REGISTER[17]="0"
declare -r   s2='18'  ; NAME[$s2]="s2"     ; REGISTER[18]="0"
declare -r   s3='19'  ; NAME[$s3]="s3"     ; REGISTER[19]="0"
declare -r   s4='20'  ; NAME[$s4]="s4"     ; REGISTER[20]="0"
declare -r   s5='21'  ; NAME[$s5]="s5"     ; REGISTER[21]="0"
declare -r   s6='22'  ; NAME[$s6]="s6"     ; REGISTER[22]="0"
declare -r   s7='23'  ; NAME[$s7]="s7"     ; REGISTER[23]="0"
declare -r   t8='24'  ; NAME[$t8]="t8"     ; REGISTER[24]="0"
declare -r   t9='25'  ; NAME[$t9]="t9"     ; REGISTER[25]="0"
declare -r   k0='26'  ; NAME[$k0]="k0"     ; REGISTER[26]="0"
declare -r   k1='27'  ; NAME[$k1]="k1"     ; REGISTER[27]="0"
declare -r   gp='28'  ; NAME[$gp]="gp"     ; REGISTER[28]="0"
declare -r   sp='29'  ; NAME[$sp]="sp"     ; REGISTER[29]="0"
declare -r   fp='30'  ; NAME[$fp]="fp"     ; REGISTER[30]="0"
declare -r   ra='31'  ; NAME[$ra]="ra"     ; REGISTER[31]="0"

declare -r  _pc='50'  ; NAME[$_pc]="_pc"   ; REGISTER[50]="0"
declare -r  _hi='51'  ; NAME[$_hi]="_hi"   ; REGISTER[51]="0"
declare -r  _lo='52'  ; NAME[$_lo]="_lo"   ; REGISTER[52]="0"

declare -r _npc='60'  ; NAME[$_npc]="_npc" ; REGISTER[60]="0"
declare -r  _ir='61'  ; NAME[$_ir]="_ir"   ; REGISTER[61]="0"
 
declare -r _mar='70'  ; NAME[$_mar]="_mar" ; REGISTER[70]="0"
declare -r _mbr='71'  ; NAME[$_mbr]="_mbr" ; REGISTER[71]="0"


function name() {
  local index="${1%,}"
  echo "${NAME[ ${index} ]}"
}
function rval() {
  local index="${1%,}"
  echo "${REGISTER[ ${index} ]}"
}


## Can assign a non-number in a register.
## For example an unresolved label
## E.g.,    assign $ra _exit
function assign () {
  local index="${1%,}"
  local value=$(parse_literal "$2")

  # Recall that the shell has 64 bits.
  # Force the value to be within the range of 32-bits
  REGISTER[ ${index} ]="$(sign_extension_word ${value})"

  # NOTE: destructive modifies bit #32..63
}


function assign_registers() {
  local value=$(parse_word "$1")

  [[ $# != 0 ]]  || { assign_registers_random ; return ; }

  assign $zero "0";  

  local i
  for ((i=1; i<32; i++)) ; do
    assign $i "$value"
  done

  assign $_hi "$value"
  assign $_lo "$value"
}


function assign_registers_random () {
  local max="$1"

  assign $zero "0"

  local i 
  for ((i=1; i<32; i++)) ; do
   assign $i "$(random_value $max)"
  done

  assign $_hi "$(random_value $max)"
  assign $_lo "$(random_value $max)"
}

function random_value() {
  local max=0xFFFF
  [[ -z "$1" ]] ||  max="$1"

  echo "$(( RANDOM % max + 1))"
}

function print_registers() {
  local i 

  if [[ ${#} == 0 ]] ; then 
    for ((i=0; i<32; i++)) ; do
      print_register $i
    done
    echo
    print_register $_pc
    print_register $_hi
    print_register $_lo
  else
    for i in "${@}" ; do
      print_register "$i"
    done
  fi
}

