#!/bin/bash

data_start=0x04000000
data_next=$data_start
data_limit=0x0FFFFFFF
heap_start=$((data_top + 1))
stack_top=0x7FFFFFFF

declare -i MEM

alias allocate_data_memory() {
   local _size="$1"
   (( data_next = data_next + _size ))
}

function assign_data_label() {
   local _label="$1"
   local _size="$2"

   alias data_label_${label}  2>&1 > /dev/null
   if [[ $? == 0 ]] ; then 
      alias data_label_${_label}=$data_next
   else
   	  instruction_error "$_label has already been used as a label!"
   fi 
}

function assign_text_label() {
   local _label="$1"

   alias text_label_${label}  2>&1 > /dev/null
   if [[ $? == 0 ]] ; then 
      alias text_label_${_label}=${REGISTER[$pc]}
   else
   	  instruction_error "$_label has already been used as a label!"
   fi 
}

function check_alignment() {
	local MAR=$1
	local SIZE=$2

	if (( $MAR % $SIZE != 0 )) ; then
       instruction_error "segmentation fault"
    fi
}

function read() {
	local MAR="$1"
	local SIZE="$2"
    local _value=
    local _index=${MAR}

    check_alignment $MAR $SIZE

    for (( i=0 ; i < $SIZE ; i++ )) ; do
      # Big Endian: first byte is msB
      _byte=${MEM[$_index]} 
      (( _value= ( _value << 8 | _byte ) ))
      (( _index++ ))
    done
    echo $_value
}

function write() {
	local MAR="$1"
	local SIZE="$2"
	local MBR="$3"
	local _value=$MBR
	local _index=$(( MAR + SIZE - 1))

    check_alignment $MAR $SIZE

    for (( i=0 ; i < $SIZE ; i++ )) ; do
      # Big Endian: first byte is msB
      # so start with last byte
      (( _byte =  _value  & 0xFF ))
      MEM[${_index}]=$_byte
      (( _value =  _value >> 8 ))
      (( _index-- ))
    done

}
