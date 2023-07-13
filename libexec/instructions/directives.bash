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
alias .end_macro="echo .end_macro improperly encountered."

alias .pseudo="read_macro pseudo"
alias .end_pseudo="echo .end_macro improperly encountered."

function .asciiz () {
   local str="$1"

   .ascii "$str\0"
}

function .ascii () {
  local str="$1"
  local i
  local j

  for i in $(ascii.index "$str") ; do
     allocate_data_memory 1 "$i"
  done
  print_string_encoding "$str"
  print_memory ${DATA_LAST} ${#str[@]}
}


function .space () {
   local bytes="$1"

   allocate_data_memory $bytes
   print_zero_encoding $bytes
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

  allocate_data_memory $bytes "$value"

  if (( bytes == 8 )) ; then 
     print_memory_encoding_multiple ${DATA_LAST} $bytes $(upper_word $value) $(lower_word $value)
  else
    print_memory_encoding ${DATA_LAST} $bytes $value ""
  fi
  print_memory ${DATA_LAST} $bytes

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
   offset=$((DATA_NEXT % size))
   bytes=$(( size - $_offset ))
   [[ $offset == 0 ]] || allocate_data_memory $bytes

   [[ ${EMIT_ENCODINGS} == "TRUE" ]] || return
   if (( offset != 0 )) ; then 
     text="$(printf "Aligning to %s boundary: 0x%0x %% %d == 0" "$text" ${DATA_NEXT} $size)"
     print_memory_encoding ${DATA_LAST} $bytes "0" "$text"
   fi

   # Note: No need to print memory
}


