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
  local value="$1"

  .align 3
  allocate_data_memory 8 "$value"
  [[ ${EMIT_ENCODINGS} == "TRUE" ]] || return
  print_memory_value $(( DATA_NEXT-2 )) $value 16

}

function .word () {
  local value="$1"

  .align 2
  allocate_data_memory 4 "$value"

  [[ ${EMIT_ENCODINGS} == "TRUE" ]] || return
  print_memory_value $(( DATA_NEXT-2 )) $value 8

}

function .half () {
   local value="$1"

   .align 1
   allocate_data_memory 2 "$value"

   [[ ${EMIT_ENCODINGS} == "TRUE" ]] || return
   print_memory_value $(( DATA_NEXT-2 )) $value 4

}    



function .byte () {
   local value="$1"

   .align 0
   allocate_data_memory 1 "$value"

   [[ ${EMIT_ENCODINGS} == "TRUE" ]] || return
   print_memory_value $(( DATA_NEXT-2 )) $value 2

}

function .align () {
  # (0=byte, 1=half, 2=word, 3=double)
  local align="$1"

  local _offset
  case ${align} in 
    0) # No adjustment is needed
       ;;
    1) _offset=$((DATA_NEXT % 2))
       [[ $_offset == 0 ]] || allocate_data_memory $(( 2 - $_offset ))
       ;;
    2) _offset=$((DATA_NEXT % 4))
       [[ $_offset == 0 ]] || allocate_data_memory $(( 4 - $_offset ))
       ;;
    3) _offset=$((DATA_NEXT % 8))
       [[ $_offset == 0 ]] || allocate_data_memory $(( 8 - $_offset ))
       ;;
   esac
}



function print_memory_value () {
  local _address="$1"
  local _rval="$2"
  local _size="$3"   # measured in nibbles

  local _dec=${_rval}
  local _unsigned=$(( _rval & 0xFFFFFFFF ))
  local _hex=$(to_hex $_size $_unsigned )
  local _bin=$(to_binary "${_hex}")
  printf "  0x%6x:  %11s %11s; 0x%s; 0b%s;"  \
        "${_address}" "${_dec}" "${_unsigned}" "${_hex}" "${_bin}"
  printf "\n"
}