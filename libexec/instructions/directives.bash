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

alias .macro="read_macro"    # Note this fuction is in the macros.bash file
alias .end_macro="echo .end_macro improperly encountered."

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
  print_memory_value $(( DATA_NEXT-8 )) 8

}

function .word () {
  local value="$1"

  .align 2
  allocate_data_memory 4 "$value"

  [[ ${EMIT_ENCODINGS} == "TRUE" ]] || return
  print_memory_value $(( DATA_NEXT-4 )) 4

}

function .half () {
   local value="$1"

   .align 1
   allocate_data_memory 2 "$value"

   [[ ${EMIT_ENCODINGS} == "TRUE" ]] || return
   print_memory_value $(( DATA_NEXT-2 )) 2

}    



function .byte () {
   local value="$1"

   .align 0
   allocate_data_memory 1 "$value"

   [[ ${EMIT_ENCODINGS} == "TRUE" ]] || return
   print_memory_value $(( DATA_NEXT-1 )) 1

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
  local _size="$2"   

  data_memory_read $_size $_address   #This ensure ENDIANESS is address
  local _rval=$(rval $_mbr)


  local _dec=${_rval}
  local _unsigned=$(( _rval & 0xFFFFFFFF ))
  local _hex=$(to_hex $(( _size << 1)) $_unsigned )
  local _bin=$(to_binary "${_hex}")

  local _dash="$( sed -e 's/./-/g' <<< $_bin )"
  local _value="$( sed -e 's/./ /g' -e 's/^...../value/' <<< $_bin )"

  # Need to deal with big versers Little Endian
  printf "| address    | %s |\n" "$_value"
  printf "|------------|-%s-|\n" "$_dash"
  printf "| 0x%8x | %s | \"0x%s\""  \
        "${_address}" "${_bin}" "${_hex}"
  printf "\n"
}