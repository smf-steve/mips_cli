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


function .data () {
  segment=".data"
  PS1="(mips.data) "
}

function .dword () {
  local value="$1"
  if [[ "$segment" != ".data" ]] ; then 
    instruction_error "Only allowed in .data segment"
  fi

  .align 3
  allocate_data_memory 4 "$value"
}

function .word () {
  local value="$1"
  if [[ "$segment" != ".data" ]] ; then 
    instruction_error "Only allowed in .data segment"
  fi

  .align 2
  allocate_data_memory 4 "$value"
}

function .half () {
   local value="$1"
   if [[ "$segment" != ".data" ]] ; then 
   	 instruction_error "Only allowed in .data segment"
   fi

   .align 1
   allocate_data_memory 2 "$value"
}

function .byte () {
   local value="$1"
   if [[ "$segment" != ".data" ]] ; then 
   	 instruction_error "Only allowed in .data segment"
   fi

   .align 0
   allocate_data_memory 1 "$value"
}

function .align () {
  # (0=byte, 1=half, 2=word, 3=double)
  local align="$1"
  if [[ "$segment" != ".data" ]] ; then 
  	 instruction_error "Only allowed in .data segment"
  fi

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

