alias .text=":"
alias .data=":"

alias .include="include"

alias .ktext="echo Not Implemented:"
alias .kdata="echo Not Implemented:"

alias .float="echo Not Implemented."
alias .double="echo Not Implemented"

alias .globl="echo Not Implemented."
alias .extern="echo Not Implemented."

alias .macro="echo Not Implemented."
alias .end_macro="echo Not Implemented."

alias .eqv="echo Not Implemented."
alias .set="echo Not Implemented."

alias .macro="read_macro macro"    # Note this fuction is in the macros.bash file
alias .pseudo="read_macro pseudo"

alias .end_macro="echo .end_macro improperly encountered."
alias .end_pseudo="echo .end_macro improperly encountered."

function .asciiz () {
   local str="$1"

   .ascii "$str"
   allocate_data_memory 1 0x00
}

function .ascii () {
  local str="$1"
  local i

  for i in $(ascii.index "$str") ; do
     allocate_data_memory 1  "$i"
  done
}

function .space () {
   local count="$1"
   allocate_data_memory count
}

function .dword () {
   # 8 = 2*3
  local value="$1"
  local address="${DATA_NEXT}"

  .align 3
  allocate_data_memory 8 "$value"

  print_memory_encoding_multiple $address $(upper $value) $(lower $value) ""

  print_memory $address 1
}

alias .word="allocate 2"
alias .half="allocate 1"
alias .byte="allocate 0"
function allocate () {
  local alignment="$1" ; shift
  local value="$1"
  local bytes="$(( 2 ** alignment ))"

  .align $alignment

  # We can enhance this function to allow multiple values
  # Generate a loop to process each $1, $2, ... in turn
  allocate_data_memory $bytes "$value"
  print_memory_encoding ${DATA_LAST} $bytes $value ""
  print_memory ${DATA_LAST} $bytes

}


function .align () {
  # (0=byte, 1=half, 2=word, 3=double)
  local align="$1"
  local text

  local _offset=0
  case ${align} in 
    0) # No adjustment is needed
       bytes=1
       text="byte"
       ;;
    1) bytes=2
       text="half"
       ;;
    2) bytes=4
       text="word"
       ;;
    3) bytes=8
       text="double"
       ;;
   esac
   _offset=$((DATA_NEXT % bytes))
   allocate=$(( bytes - $_offset ))
   [[ $_offset == 0 ]] || allocate_data_memory $allocate

   if (( _offset != 0 )) ; then 
     text="$(printf "Aligning to %s boundary: 0x%0x %% %d == 0" "$text" ${DATA_NEXT} $bytes)"
     print_memory_encoding $(( DATA_LAST )) $allocate "0" "$text"
   fi

   # Note: No need to print memory
}


