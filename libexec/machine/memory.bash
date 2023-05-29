#!/bin/bash

ENDIANNESS="LITTLE"
data_start=0x04000000
data_next=$data_start
data_limit=0x0FFFFFFF
heap_start=$((data_top + 1))
stack_top=0x7FFFFFFF

declare -a MEM

function allocate_data_memory() {
   local _size="$1"
   (( data_next = data_next + _size ))
}


function print_data_memory() {
   # Lets assume
   #  1. we print out each segment separately
   #  1. we have the first and last for each segement
   # For now, just print the data segment.

   
   _rows=$((  ${#MEM[@]} / 4 ))
   _cols=$((  ${#MEM[@]} % 4 ))
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



function check_alignment() {
	local _address=$1
	local _size=$2

   if ((_address < $data_start ||  _address > $stack_top)) ; then
      instruction_error "protection error"
   fi
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


function data_memory_read() {
  local _size="$1"

  local _value=
  local _index=$(rval ${_mar})

  check_alignment $(rval $_mar) $_size

  for (( i=0 ; i < $_size ; i++ )) ; do
    # Big Endian: first byte is msB

     local _byte=${MEM[$_index]} 
     (( _value= ( _value << 8 | _byte ) ))
     (( _index++ ))
  done
  assign $_mbr $_value
}

function data_memory_write() {
  local _size="$1"

  local _mar_value=$(rval $_mar)
  local _value=$(rval $_mbr)

  local _index=$(( _mar_value + _size - 1))
  check_alignment $_mar_value $_size

  local _index=$(( _mar_value + _size - 1))
  for (( i=0 ; i < $_size ; i++ )) ; do
    # Big Endian: first byte is msB
    # so start with lsB first
    local _byte

    (( _byte =  _value  & 0xFF ))
    MEM[${_index}]=$_byte
    (( _value =  _value >> 8 ))
    (( _index-- ))
  done
}
