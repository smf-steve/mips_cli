#!/bin/bash

declare -a MEM
declare -a DATA
declare -a HEAP
declare -a STACK

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

function print_data_memory() {
   # Lets assume
   #  1. we print out each segment separately
   #  1. we have the first and last for each segement
   # For now, just print the data segment.
   #    (mips) echo ${!REGISTER[@]}

   local allocated
   local _cols
   local _rows
   local _item_count
   local _current

   (( allocated = data_next - data_start ))
   _rows=$((  allocated / 4 ))
   _cols=$((  allocated % 4 ))
   if (( _cols != 0 )) ; then
      (( _rows ++ ))
   fi
   _item_count=$(( _rows * 4 ))
  
   _current=$data_start
   if [[ "$ENDIANNESS" == "BIG" ]] ; then
     printf "%-10s:\t %4d\t %4d\t %4d\t %4d\n" address 1 2 3 4
     for (( i=0; i < _item_count && _current < data_next; i+=4, _current+=4 )) ; do
       printf "0x%08x:\t 0x%02x\t 0x%02x\t 0x%02x\t 0x%02x\n"  $_current \
       "${MEM[$_current]}" "${MEM[$_current+1]}" "${MEM[$_current+2]}" "${MEM[$_current+3]}"
     done
  else
    printf "%-10s:\t %4d\t %4d\t %4d\t %4d\n" address 4 3 2 1
    for (( i=0; i < _item_count && _current < data_next; i+=4, _current+=4 )) ; do
      printf "0x%08x:\t 0x%02x\t 0x%02x\t 0x%02x\t 0x%02x\n"  $_current \
      "${MEM[$_current+3]}" "${MEM[$_current+2]}" "${MEM[$_current+1]}" "${MEM[$_current]}"
    done
  fi

}


function check_segment () {
  local address="$1"
  local segment        # return value:  "data", "heap", "stack"

  # From bottom to top:
  # stack_start
  # $(rval $fp) === stark_end
  # heap_end
  # heap_start
  # data_end
  # data_start
  # text_end
  # text_start

  while true ; do 

    if (( address == 0 )) ; then 
      instruction_error "Address is NULL"
      break
    fi
    if (( address < text_start  || stack_start < address ))  ; then 
      instruction_error "Kernel space is inaccessible to user"
      break
    fi

    if (( address < data_start ))  ; then 
      instruction_error "Text segment is inaccessible via the data path"
      break
    fi

    if (( data_start <= address  &&  address <= data_next ))  ; then 
      segment="DATA"
      break
    fi

    if (( heap_start <= address  &&  address <= ${HEAP[${heap_start}]} ))  ; then 
      segment="HEAP"
      break
    fi

    # Recall the stack grows downwards
    if (( $(rval $sp) <= address &&  address <= $stack_start ))  ; then 
      segment="STACK"
      break
    fi
  
    instruction_warning "read/write between stack and heap"
    instruction_warning "Best practice is to up \$sp prior to performing memory operation"
    segment="STACK" 
    break
  done
  echo $segment
}

function check_alignment() {
	local _address=$1
	local _size=$2

   case $_size in
      1|2|4)
        	if (( _address % _size != 0 )) ; then
            instruction_error "alignment error"
         fi
         ;;
      *) instruction_error "bus error"
         ;;
   esac
}



# Usage: data_memory_{read/write}
#   1.   .word 45          --> data_memory_write 4 $data_next 45
#   2.   sw $t1, imm ($t2) --> data_memory_write 4
#      - the value of the MAR and MBR are latched in

function data_memory_read() {
  local _size="$1"
  local _address="$2"

  local _value=

  if [[ -z "$_address" ]] ; then 
    _address=$(rval $_mar)
  fi

  check_alignment $_address $_size
  local segment=$(check_segment $_address)

  local _index=$_address
  local i
  for (( i=0 ; i < $_size ; i++ )) ; do
    # Big Endian: first byte is msB
     local _byte
     eval _byte=\${${segment}[$_index]} 
     (( _value= ( _value << 8 | _byte ) ))
     (( _index++ ))
  done
  assign $_mbr $_value
}

function data_memory_write() {
  local _size="$1"
  local _address="$2"
  local _value="$3"

  if [[ -z "$_address" ]] ; then 
    _address=$(rval $_mar)
  fi
  if [[ -z "$_value" ]] ; then 
    _value=$(rval $_mbr)
  fi

  check_alignment $_address $_size
  local segment=$(check_segment $_address)

  local _index=$(( _address + _size - 1))
  local i 
  for (( i=0 ; i < $_size ; i++ )) ; do
    # Big Endian: first byte is msB
    # so start with lsB first
    local _byte

    (( _byte =  _value  & 0xFF ))
    eval ${segment}[${_index}]=$_byte
    (( _value =  _value >> 8 ))
    (( _index-- ))
  done
}
