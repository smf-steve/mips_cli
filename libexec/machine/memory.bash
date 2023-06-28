#!/bin/bash

function allocate_data_memory() {
   local _size="$1"
   local _value="$2"

   # The issue here is that we need to place a zero or some value in each location
   # others
   if [[ -n $_value ]]; then 
     data_memory_write $_size $DATA_NEXT $_value
   fi
   (( DATA_LAST = DATA_NEXT ))
   (( DATA_NEXT = DATA_NEXT + _size ))
}

function print_memory() {
  local segment="$1"
  if [[ -z ${segment} ]] ; then
    segment=DATA
  fi
  case "$segment" in 
    TEXT  ) start=$TEXT_START
            last=$TEXT_NEXT
            ;;
    DATA  ) start=$DATA_START
            last=$DATA_NEXT
            #
            ;;
    HEAP  ) start=$HEAP_START
            last=$HEAP_NEXT
            ;;
    STACK ) start=$STACK_START
           last=$STACK_NEXT
             # Perhaps the stack should be presented in reverse
  esac

  if [[ "$ENDIANNESS" == "BIG" ]] ; then
    printf "${segment}:\t\t  +3\t  +2\t+  1\t  +0\n"
  else
    printf "${segment}:\t\t  +0\t  +1\t  +2\t  +3\n"
  fi

  for (( i = $start ; i < $last ; i+=4 )) ; do
    printf  "[0x%x]\t" ${i}
    if [[ "$ENDIANNESS" == "BIG" ]] ; then
      for (( j=0; j<4 ; j++ )) ; do
        (( index = i + j ))
        eval value="\${${segment}[${index}]}"
        if [[ -n "${value}" ]] ; then
           printf "0x%02x\t" ${value}
        else
           printf -- " --\t"
        fi
      done
      echo
    else
      for (( j=3; j>=0 ; j-- )) ; do
        (( index = i + j ))
        eval value="\${${segment}[${index}]}"
        if [[ -n "${value}" ]] ; then
           printf "0x%02x\t" ${value}
        else
           printf -- " --\t"
        fi
      done
      echo
    fi
  done
  echo

}


function check_segment () {
  local address="$1"
  local segment        # return value:  "DATA", "HEAP", "STACK"

  # From bottom to top:
  # STACK_START
  # $(rval $fp) === STACK_END
  # HEAP_END
  # HEAP_START
  # DATA_END
  # DATA_START
  # TEXT_END
  # TEXT_START

  while true ; do 

    if (( address == 0 )) ; then 
      instruction_error "Address is NULL"
      break
    fi
    if (( address < TEXT_START | STACK_START < address ))  ; then 
      instruction_error "Kernel space is inaccessible to user"
      break
    fi

    if (( address < DATA_START ))  ; then 
      instruction_error "Text segment is inaccessible via the DATA path"
      break
    fi

    if (( DATA_START <= address  &&  address <= DATA_NEXT ))  ; then 
      segment="DATA"
      break
    fi

    if (( HEAP_START <= address  &&  address <= ${HEAP[${HEAP_START}]} ))  ; then 
      segment="HEAP"
      break
    fi

    # Recall the STACK grows downwards
    if (( $(rval $sp) <= address &&  address <= $STACK_START ))  ; then 
      segment="STACK"
      break
    fi
  
    instruction_warning "read/write between STACK and HEAP"
    instruction_warning "Best practice is to up \$sp prior to performing memory operation"
    segment="STACK" 
    break
  done
  echo "${segment}"
}

function check_alignment() {
	local _address=$1
	local _size=$2

   case $_size in
      1|2|4|8)
        	if (( _address % _size != 0 )) ; then
            instruction_error "alignment error"
         fi
         ;;
      *) instruction_error "bus error"
         ;;
   esac
}



# Usage: data_memory_{read/write}
#   1.   .word 45          --> data_memory_write 4 $DATA_NEXT 45
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
