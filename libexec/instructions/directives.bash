#! /bin/bash

#################################################################################
# This file contains the declarations of all supported MIPS directives.
#
# The directives supported are:
#
#   .align
#   .dword
#   .word
#   .half
#   .byte
#   .asciiz
#   .ascii
#   .space
#
# Note that data directives may only provide a single optional data. E.g.,
#   .word             # valid
#   .word 42          # valid
#   .word 42, 0, 42   # invalid
#################################################################################


alias .text=":"
alias .ktext="echo Not Implemented."

alias .data=":"
alias .kdata="echo Not Implemented."

alias .float="echo Not Implemented."
alias .double="echo Not Implemented."

alias .globl="echo Not Implemented."
alias .extern="echo Not Implemented."

alias .eqv="echo Not Implemented."
alias .set="echo Not Implemented."

alias .include="include"

alias .macro="read_macro macro"
alias .end_macro="instruction_error \".end_macro improperly encountered.\""

alias .pseudo="read_macro pseudo"
alias .end_pseudo="instruction_error \".end_pseudo improperly encountered.\""

function .asciiz () {
   local str="$1"

   .ascii "$str\0"
}

function .ascii () {
  local str="$1"
  local i
  local address=${DATA_NEXT}
  local count=0

  for i in $(ascii.index "$str") ; do
     allocate_data_memory 1 "$i"
     (( count ++ ))
  done
  print_string_encoding "$str"
  print_data_memory $address ${count} 
}

function .space () {
   local bytes=$(parse_literal "$1")

   allocate_data_memory $bytes
   print_zero_encoding $bytes
}


function .align () {
  # (0=byte, 1=half, 2=word, 3=double)
  local align="$1"
  local text

  local offset=0
  local bytes
  case ${align} in 
    0) # No adjustment is needed
       size=1
       text="byte"
       ;;
    1) size=2
       text="half"
       ;;
    2) size=4
       text="word"
       ;;
    3) size=8
       text="double"
       ;;
   esac
   offset=$(( DATA_NEXT % size))
   bytes=$(( size - $offset ))
   [[ $offset == 0 ]] || allocate_data_memory $bytes

   [[ ${EMIT_ENCODINGS} == "TRUE" ]] || return
   if (( offset != 0 )) ; then 
     text="$(printf "Aligning to %s boundary: 0x%0x %% %d == 0" "$text" ${DATA_NEXT} $size)"
     print_memory_encoding ${DATA_LAST} $bytes "0" "$text"
   fi

   # Note: No need to print memory
}

alias .dword="allocate 3"
alias .word="allocate 2"
alias .half="allocate 1"
alias .byte="allocate 0"
function allocate () {
  local alignment="$1" ; shift
  local value="$1" ; [[ -n $value ]] || value=0
  local bytes="$(( 2 ** alignment ))"

  .align $alignment

  # Insert Santity Check for size of the value
  value=$(parse_literal "$value")

  allocate_data_memory $bytes "$value"

  if (( bytes == 8 )) ; then 
     print_memory_encoding_multiple ${DATA_LAST} $bytes $(upper_word $value) $(lower_word $value)
  else
    print_memory_encoding ${DATA_LAST} $bytes $value ""
  fi
  print_data_memory ${DATA_LAST} $bytes

}
