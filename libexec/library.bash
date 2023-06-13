#! /bin/bash

# CONSTANTS
min_shamt=0
max_shamt=$(( 2 ** 5 ))

max_immediate_unsigned=$(( 2 ** 16 - 1))
min_immediate=$(( - 2 ** 15  ))
max_immediate=$(( - min_immediate - 1 ))

max_word_unsigned=$(( 2 ** 32 - 1))
min_word=$(( - 2 ** 31  ))
max_word=$(( - min_word - 1 ))

max_dword_unsigned=$(( 2 ** 64 - 1))
min_dword=$(( - 2 ** 63 ))
max_dword=$(( - max_dword -1  ))



##########################################################################
## Following are functions to convert output to more readable formats

## Convert a decimal number to hex with bytes separated
#    - format "0x XX XX XX XX XX"
function to_hex () {
  local _size=${1}
  local _decimal=${2}
  local _hex=$(printf "%0${_size}X" ${_decimal} )

  # Make it a byte at a time:
  sed -e 's/\(..\)/ \1/g' -e 's/^ //' <<< $_hex
}

## Convert a hexadecimal number to binary with nibbles separated
#    - format "bbbb bbbb bbbb bbbb"
function to_binary () {
  local _hex=${1}
  # Make it a nibble at a time
  local _exploded=$(sed -e 's/ //g' -e 's/\(.\)/ \1/g' <<< $_hex)
  local _value=""

  for i in $_exploded ; do
    case $i in 
       0   ) _value="${_value} 0000" ;;
       1   ) _value="${_value} 0001" ;;
       2   ) _value="${_value} 0010" ;;
       3   ) _value="${_value} 0011" ;;
       4   ) _value="${_value} 0100" ;;
       5   ) _value="${_value} 0101" ;;
       6   ) _value="${_value} 0110" ;;
       7   ) _value="${_value} 0111" ;;
       8   ) _value="${_value} 1000" ;;
       9   ) _value="${_value} 1001" ;;
       a|A ) _value="${_value} 1010" ;;
       b|B ) _value="${_value} 1011" ;;
       c|C ) _value="${_value} 1100" ;;
       d|D ) _value="${_value} 1101" ;;
       e|E ) _value="${_value} 1110" ;;
       f|F ) _value="${_value} 1111" ;;
    esac
  done
  echo "${_value}"
}

# below is defunct!
function sign_contraction () {
    # In bash, a numbers are a 64-bit value.
    # Only the bottom 32 bits are necessary.
    local _bit_31
    local _upper_word

    echo "$(( $1 & 0xFFFFFFFF ))"

    # Do some error checking based upon the value of bit 31
    # should have been replicated in bits 63-32

    (( _bit_31    = $1 & 0x80000000 ))
    ((_upper_word = $1 >> 32 ))
    if (( _bit_31 == 0 && _upper_word == 0 )) ; then
      return
    fi
    if (( _upper_word == 0xFFFFFFFF )) ; then
      return
    fi
    
    echo "Error: The value is not in the range of - 2^31 .. 2^31-1: $1"
    # exit
}

function sign_extension_byte() {
  local _value="$1"
  local _sign_bit

   _sign_bit=$(( ${_value} & 0x80 ))
  if [[ ${_sign_bit} != 0 ]] ; then 
    # The sign bit is on... so extend it
    ((_value = ( - 0x80 ) | _value ))
  fi
  echo "${_value}"
}

function sign_extension() {
  # The input value as a text value can be:
  #   -n, ~n, or a 16bit number
  # For the first two, leave the value alone
  # For a 16-bit number transform it into a 32-bit number
  #   
  local _value="$1"
  local _prefix=${_value:0:1}
  local _sign_bit

  if [[ ${_prefix} == '~' || ${_prefix} == '-' ]] ; then 
  	_value="${_value:1}"
  else
  	_prefix=
  fi

  # 0x80000000 == 2 ** 15
  _sign_bit=$(( ${_value} & 0x8000 ))
  if [[ ${_sign_bit} != 0 ]] ; then 
   	# The sign bit is on... so extend it
    ((_value = ( - 0x8000 ) | _value ))
  fi
  
  echo "${_prefix}${_value}"
}



function ascii.index () {
    str="$*"
    for (( i = 0; i < ${#str}; i++ )) ; do 
        printf "%d " "'${str:i:1}"
    done
    printf "\n"
}

function ascii.char () {
   for i in $@   ; do 
       printf \\$(printf '%03o' $(( $i )) )
   done
   printf "\n"
}

