#! /bin/bash

#################################################################################
# This file contains the declarations of all supported MIPS directives, and some
# additional directives
#
# The segment directives that are supported are:
#
#    .text  -- as with MARS, .text is the default segment
#    .data
#
# The data directives supported are:
#
#   .align  { 1 | 2 | 3 | 4 }  # 1=byte, 2=half, 3=word, 4=dword
#   .dword  [ value ]
#   .word   [ value ]
#   .half   [ value ]
#   .byte   [ value ]
#   .asciiz "a string"
#   .ascii  "a string"
#   .space  number
#
#################################################################################

#################################################################################
# Additional directives
#
#    .lab   label [address]
#    .label label [address]  : an extension of the .lab directive where an address
#                              can be provided
#
#    .macro_define   : equivalent to .macro
#    .macro_start    : equivalent to a nop, indicates the start of an applied macro instruction
#    .macro_stop     : akin to .end_macro
#    .pseudo         : akin to .macro, but a pseudo instruction is being created
#    .pseudo_define  : equivalen to .pseudo
#    .pseudo_start   : equivalent to a nop, indicates the start of an applied pseudo instruction
#    .pseudo_stop    : akin to .end_macro
#
#################################################################################

declare SEGMENT="TEXT"
alias assert_DATA_segment='[[ ${SEGMENT} == "DATA" ]]  || { instruction_error "Must use the .data directive first" ; }'
alias assert_TEXT_segment='[[ ${SEGMENT} == "TEXT" ]]  || { instruction_error "Must use the .text directive first" ; }'

alias .lab=".label"
function .label () {
  local name="$1"
  local address="$2"
  local _segment="$(tr [A-Z] [a-z] <<< "${SEGMENT}")"

  [[ -n "$address" ]] || address=$(( $(rval $_pc) - 4 ))

  # note that it overwrites the label
  eval ${_segment}_label_${name}="${address}"
}

alias .text="SEGMENT=TEXT"
alias .ktext="SEGMENT=KTEXT"

alias .data="SEGMENT=DATA"
alias .kdata="SEGMENT=KDATA"

alias .float="echo Not Implemented."
alias .double="echo Not Implemented."

alias .globl="echo Not Implemented."
alias .extern="echo Not Implemented."

alias .eqv="echo Not Implemented."
alias .set="echo Not Implemented."

alias .include="include"

alias .macro="read_macro macro"
alias .macro_define="read_macro macro"
alias .end_macro="instruction_error \".end_macro improperly encountered.\""

alias .pseudo="read_macro pseudo"
alias .pseudo_define="read_macro pseudo"
alias .end_pseudo="instruction_error \".end_pseudo improperly encountered.\""

alias .macro_start="start_macro macro"
alias .macro_stop="stop_macro macro"
alias .pseudo_start="start_macro pseudo"
alias .pseudo_stop="stop_macro pseudo"

function .asciiz () {
   local str="$1"

   .ascii "$str\0"
}

function .ascii () {
  local str="$1"
  local i
  local address=${DATA_NEXT}
  local count=0

  assert_DATA_segment
  for i in $(ascii.index "$str") ; do
     allocate_data_memory 1 "$i"
     (( count ++ ))
  done
  print_string_encoding $address "$str"
  print_data_memory $address ${count} 
}

function .space () {
   local bytes=$(parse_literal "$1")

   assert_DATA_segment
   allocate_data_memory $bytes
   print_zero_encoding $bytes
}


function .align () {
  # (0=byte, 1=half, 2=word, 3=double)
  local align="$1"

  local text
  local offset=0
  local bytes

  assert_DATA_segment
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
