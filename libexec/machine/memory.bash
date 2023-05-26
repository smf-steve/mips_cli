#!/bin/bash

data_start=0x04000000
data_next=$data_start
data_limit=0x0FFFFFFF
heap_start=$((data_top + 1))
stack_top=0x7FFFFFFF

declare -a MEM
declare -a DATA_LABELS
declare -a TEXT_LABELS

<<<<<<< HEAD
=======
Need a way to keep track of labels used but not assign

>>>>>>> e32e766d003c11fac26737d05a620437d673127f
function allocate_data_memory() {
   local _size="$1"
   (( data_next = data_next + _size ))
}

function assign_data_label() {
   local _label="$1"
   local _size="$2"

   alias data_label_${_label}  >/dev/null 2>&1 
   if [[ $? == 1 ]] ; then 
      alias data_label_${_label}=$data_next
      allocate_data_memory $_size                  # Maybe not move this forward yet
   else
   	instruction_error "$_label has already been used as a label."
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


function memory_read() {
  local _size="$1"

  local _value=
  local _index=${_mar}

  check_alignment $(rval $_mar) $_size

  for (( i=0 ; i < $_size ; i++ )) ; do
    # Big Endian: first byte is msB

     local _byte=${MEM[$_index]} 
     (( _value= ( _value << 8 | _byte ) ))
     (( _index++ ))
  done
  assign $_mbr $_value
}

function memory_write() {
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
