#!/bin/bash

data_start=0x04000000
data_next=$data_start
data_limit=0x0FFFFFFF
heap_start=$((data_top + 1))
stack_top=0x7FFFFFFF

declare -a MEM
declare -a DATA_LABELS
declare -a TEXT_LABELS

function allocate_data_memory() {
   local _size="$1"
   (( data_next = data_next + _size ))
}

function assign_data_label() {
   local _label="$1"
   local _value

   _value=$(eval echo \$data_label_${_label})
   if [[ -z "${_value}" || "${_value}" == "undefined" ]] ; then   
      eval data_label_${_label}=$data_next
   else
   	instruction_error "\"$_label\" has already been used as a label."
   fi 
}

function use_text_label() {
  local _label=$1
  local _value

  _value=$(eval echo \$text_label_${_label})
  if [[ -z "${_value}" ]] ; then
    eval text_label_${_label}="undefined"
  fi
}

function assign_text_label() {
   local _label="$1"
   local _value

   _value=$(eval echo \$text_label_${_label})
   if [[ -z "${_value}" || "$_value" == "undefined" ]] ; then
     # This is the first time in which the label is being defined.
     eval text_label_${_label}=${REGISTER[$pc]}
   else
   	instruction_error "\"$_label\" has already been used as a label."
   fi 
}

function list_labels() {
	 declare -p | grep ^data_label_
	 declare -p | grep ^text_label_
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
