#!/bin/bash

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

function use_text_label() {
  local _label=$1

  # This is called when a text label is 
  # used within a branch or j instruction
  # If the 
  declare -i text_label_${_label} 

}
function assign_text_label() {
   local _label="$1"

   declare -i text_label_${_label} 
   if (( text_label_${_label}  == "" )) ; then 
   	 declare -ri text_label_${_label}=${REGISTER[$pc]}
   else
   	  instruction_error "$_label has already been used as a label."
   fi 
}

function list_labels() {
	 declare -pi | grep data_label
	 declare -pi | grep test_label
}
function check_alignment() {
	local _address=$1
	local _size=$2

	if (( _address % _size != 0 )) ; then
       instruction_error "alignment error"
    fi
}

# appears I have the endianness wrong
# provide an option to change endianness
# Jaa is Little Endian
# MARS is a Java implementation

function read_memory() {
	local _size="$1"
    local _value=
    local _index=$(rval $_mar)

    check_alignment $(rval $_mar) $_size

    for (( i=0 ; i < $_size ; i++ )) ; do
      # Big Endian: first byte is msB

      _byte=${MEM[$_index]} 
      (( _value= ( _value << 8 | _byte ) ))
      (( _index++ ))
    done
    assign $_mbr $_value
}

function write_memory() {
	local _size="$1"

	local _mar_value=$(rval $_mar)
	local _value=$(rval $_mbr)

    check_alignment $_mar_value $_size

	local _index=$(( _mar_value + _size - 1))
    for (( i=0 ; i < $_size ; i++ )) ; do
      # Big Endian: first byte is msB
      # so start with lsB first
      (( _byte =  _value  & 0xFF ))
      MEM[${_index}]=$_byte
      (( _value =  _value >> 8 ))
      (( _index-- ))
    done
}
