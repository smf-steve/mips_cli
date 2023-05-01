#! /bin/bash


##########################################################################
## Following are functions to convert output to more readable formats

## Convert a decimal number to hex with bytes separated
#    - format "0x XX XX XX XX XX"
function to_hex () {
  _size=${1}
  _decimal=${2}
  _hex=$(printf "%0${_size}X" ${_decimal} )

  # Make it a byte at a time:
  sed -e 's/\(..\)/ \1/g' -e 's/^ //' <<< $_hex
}

## Convert a hexadecimal number to binary with nibbles separated
#    - format "bbbb bbbb bbbb bbbb"
function to_binary () {
  _hex=${1}
  # Make it a nibble at a time
  _exploded=$(sed -e 's/ //g' -e 's/\(.\)/ \1/g' <<< $_hex)
  _value=""
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
  echo $_value
}

function sign_contraction () {
    # In bash, a numbers are a 64-bit value.
    # Only the bottom 32 bits are necessary.

    echo $(( $1 & 0xFFFFFFFF ))

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

function sign_extension() {
  # first convet to an int: see mips_subroutine to accept various inputs
  #   - e.g. 0x034, 045, 0bxxx, n# 101010 100101
  # second make sure it is only 16 bits
  # 
  _value="$1"

  _prefix=${_value:0:1}
  if [[ ${_prefix} == '~' || ${_prefix} == '-' ]] ; then 
  	_value="${_value:1}"
  else
  	_prefix=
  fi

  # 0x80000000 == 2 ** 15
  _sign_bit=$(( ${_value} & 0x80000000 ))
  if [[ ${sign_bit} == 1 ]] ; then 
   	# The sign bit is on... so extend it
    ((_value = - 0x80000000 | _value ))
  fi
  
  echo $(( ${_prefix}${_value} ))
}
