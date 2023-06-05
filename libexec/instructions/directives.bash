ENDIANNESS="LITTLE"

text_start=0x00400000
text_next=$text_start
text_end=0x0FFFFFFF

data_start=0x10010000
data_next=$data_start
data_end=0x1003FFFF

heap_start=$((data_end + 1))
heap_ptr_address=$heap_start
heap_next=$heap_start+4
MEM[$heap_ptr_address]=$heap_next;

stack_top=0x7FFFFFFF
# $sp = stack_top    # does this point to the top element or
# the program args shojuld be placed here

declare -a MEM

function allocate_data_memory() {
   local _size="$1"
   local _value="$2"

   # The issue here is that we need to place a zero or some value in each location
   # others
   if [[ -n $_value ]]; then 
     data_memory_write $_size $data_next $_value
   fi
   (( data_next = data_next + _size ))
}

alias .text=":"
alias .data=":"

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


alias .ascii="echo Not Implemented."
alias .asciiz="echo Not Implemented."

function .asciiz () {
   local str="$1"

   .ascii "$str"
   allocate_data_memory 8 0x00
}

function .ascii () {
  local str="$1"

  local len=${#str}
  for (( i=0 ; i < len ; i++ )) ; do
     allocate_data_memory 1  "${str:$i:1}"
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
}

function .word () {
  local value="$1"

  .align 2
  allocate_data_memory 4 "$value"
}

function .half () {
   local value="$1"

   .align 1
   allocate_data_memory 2 "$value"
}

function .byte () {
   local value="$1"

   .align 0
   allocate_data_memory 1 "$value"
}

function .align () {
  # (0=byte, 1=half, 2=word, 3=double)
  local align="$1"

  local _offset
  case ${align} in 
    0) # No adjustment is needed
       ;;
    1) _offset=$((data_next % 2))
       [[ $_offset == 0 ]] || allocate_data_memory $(( 2 - $_offset ))
       ;;
    2) _offset=$((data_next % 4))
       [[ $_offset == 0 ]] || allocate_data_memory $(( 4 - $_offset ))
       ;;
    3) _offset=$((data_next % 8))
       [[ $_offset == 0 ]] || allocate_data_memory $(( 8 - $_offset ))
       ;;
   esac

}

