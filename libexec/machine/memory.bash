#!/bin/bash


# allocate_data_memory
# data_memory_read
# data_memory_write

# print_memory
# print_data_memory 
#   print_data_word_little 
#   print_data_word_big 
# check_segment 
# check_alignment
# map.ascii 




function allocate_data_memory () {
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




function print_memory () {
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

function check_alignment () {
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

function data_memory_read () {
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


function data_memory_write () {
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




       big_title="| address    | char | byte | half   | word        |\n"
   big_separator="|------------|------|------|--------|-------------|\n"
     big_pattern="| 0x%08x | %4s | 0x%02x | %6s | %10s |\n"
    little_title="| address    | word        | half   | byte | char |\n"
little_separator="|------------|-------------|--------|------|------|\n"
  little_pattern="| 0x%08x |  %10s | %6s | 0x%02x | %4s |\n"

function print_data_memory () {
  local address="$1"
  local count="$2"
   
  local offset=$(( address % 4 ))
  local end=$(( address - offset ))        # Adjust to ensure a complete word is provided
  local count=$(( count + offset ))        # Revise to accommodate 'end' calculation

  local start=$(( end + count - 1))
  if (( start >= DATA_NEXT )) ; then 
     start=$(( DATA_NEXT - 1 ))
  fi
  local offset=$(( start % 4 ))            # Adjust to ensure a complete word is provided
  start=$(( start +  (3 - offset ) ))

  printf "Memory: $ENDIANNESS Endian\n"
  if [[ "$ENDIANNESS" == "LITTLE" ]] ; then 
    printf "$little_title"
    printf "$little_separator"

    for (( i = start ; i >= end ; i -= 4 )) ; do 
      print_data_word_little $i
      printf "$little_separator"
    done
  else
    printf "$big_title"
    printf "$big_separator"

    for (( i = start ; i >= end ; i -= 4 )) ; do 
      print_data_word_big $i
      printf "$big_separator"
    done
  fi
}

function print_data_word_little () {
  local address="$1"
  local byte_0=${DATA[ address ]}
  local byte_1=${DATA[ (( address - 1 )) ]}
  local byte_2=${DATA[ (( address - 2 )) ]}
  local byte_3=${DATA[ (( address - 3 )) ]}

  local half_0=$( printf "0x%04x" $(( byte_0 <<  8 | byte_1 )) )
  local half_1=$( printf "0x%04x" $(( byte_2 <<  8 | byte_3 )) )
  local   word=$( printf "0x%08x" $(( half_0 << 16 | half_1 )) )

  printf "$little_pattern" $(( address ))     ""        ""          "${byte_0}" "$(map.ascii ${byte_0})"
  printf "$little_pattern" $(( address - 1 )) ""        "${half_0}" "${byte_1}" "$(map.ascii ${byte_1})"
  printf "$little_pattern" $(( address - 2 )) ""        ""          "${byte_2}" "$(map.ascii ${byte_2})"
  printf "$little_pattern" $(( address - 3 )) "${word}" "${half_1}" "${byte_3}" "$(map.ascii ${byte_3})"
}


function print_data_word_big () {
  local address="$1"
  local byte_0=${DATA[address ]}
  local byte_1=${DATA[ (( address - 1 )) ]}
  local byte_2=${DATA[ (( address - 2 )) ]}
  local byte_3=${DATA[ (( address - 3 )) ]}

  local half_0=$( printf "0x%04x" $(( byte_1 <<  8 | byte_0 )) )
  local half_1=$( printf "0x%04x" $(( byte_3 <<  8 | byte_2 )) )
  local   word=$( printf "0x%08x" $(( half_1 << 16 | half_0 )) )

  printf "$big_pattern" $(( address ))     "$(map.ascii ${byte_0})" "${byte_0}" ""          ""      
  printf "$big_pattern" $(( address - 1 )) "$(map.ascii ${byte_1})" "${byte_1}" "${half_0}" ""      
  printf "$big_pattern" $(( address - 2 )) "$(map.ascii ${byte_2})" "${byte_2}" ""          ""      
  printf "$big_pattern" $(( address - 3 )) "$(map.ascii ${byte_3})" "${byte_3}" "${half_1}" "${word}" 
}


function map.ascii () {
  local sequence=$(ascii.char $1)

   if [[ -z "$sequence" ]] ; then 
      sequence="'\0'"
   else
     case "$sequence" in
        \' ) sequence="\"'\"" ;;
        \" ) sequence="'\"'" ;;
        *)   sequence="'${sequence}'"
     esac
   fi
   echo "$sequence"
}
