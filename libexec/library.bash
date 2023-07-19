#! /bin/bash

alias upper="upper_half"
alias lower="lower_half"
function upper_half () {
  local _address=$1

  if [[ ${_address:0:1} =~ [[:alpha:]] ]] ; then
    local value=$(lookup_data_label $_address)
    [[ -n "$value" ]] || instruction_error "Label \"$_address\" not defined"
    _address=$value
  fi
  printf "0x%04x\n" $((  (_address >> 16 ) & 0xFFFF ))
}
function lower_half () {
  local _address=$1

  if [[ ${_address:0:1} =~ [[:alpha:]] ]] ; then
    local value=$(lookup_data_label $_address)
    [[ -n "$value" ]] || instruction_error "Label \"$_address\" not defined"
    _address=$value
  fi
  printf "0x%04x\n" $((  _address & 0xFFFF ))
}

function upper_word () {

   echo $(( $1 >> 32 ))
}
function lower_word () {
   echo $(( $1 & 0x00000000FFFFFFFF ))
}

##########################################################################
## Following are functions to convert output to more readable formats

# Modify these to be formatinng
# format_hex value -> 0x XX XX XX XX   (groups of nibbles)
# format_bin value -> 0b 0000 0000 0000 0000

# should be group string group len
#  - take the string, pad it to length

#  to_hex size value
#  to_binary nibble...

## Convert a decimal number to hex with bytes separated
#    - format "0x XX XX XX XX XX"

function group_4_2 () {
   # Create four groups of 2

   echo "${1:0:2} ${1:2:2} ${1:4:2} ${1:6:2}"

}
function group_8_4 () {
   # create 8 groups of 4

   echo "${1:0:4} ${1:4:4} ${1:8:4} ${1:12:4} ${1:16:4} ${1:20:4} ${1:24:4} ${1:28:4}"

}

function to_hex () {
  local _size=${1}
  local _decimal=${2}
  local _hex=$(printf "%0${_size}X" "${_decimal}" )
  
  echo "${X:0:2} ${X:2:2} ${X:4:2} ${X:6:2}"

  # Make it a byte at a time:
  sed -e 's/\(..\)/ \1/g' -e 's/^ //' <<< "${_hex}"
}

## Convert a hexadecimal number to binary with nibbles separated
#    - format "bbbb bbbb bbbb bbbb"
function to_binary () {
  local _hex=${1}
  # Make it a nibble at a time
  local _exploded=$(sed -e 's/ //g' -e 's/\(.\)/ \1/g' <<< "${_hex}")
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
  echo "${_value:1}"
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


alias ZE="base2_digits 32"
function SE () {
   # Perform Sign-exention and return bits
   local value=$(sign_extension "$1")
   echo $(base2_digits 32 $value)
}


alias zero_extension="zero_extension_half"
function zero_extension_half () {
  local value="$1"
  echo $((  value & 0xFFFF))
}



alias sign_extension="sign_extension_half"
function sign_extension_word () {
  # Take a word and perform sign-extension
  # The function works for any size of integer representation
  # Bash has 64-bits

  local _value="$1"
  local _sign_bit

   _sign_bit=$(( ${_value} & 0x80000000 ))
  if [[ ${_sign_bit} != 0 ]] ; then 
    # The sign bit is on... so extend it
    ((_value = ( - 0x80000000 ) | _value ))
  fi
  echo "${_value}"
}

function sign_extension_half() {
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

function sign_extension_byte () {
  local _value="$1"
  local _sign_bit

   _sign_bit=$(( ${_value} & 0x80 ))
  if [[ ${_sign_bit} != 0 ]] ; then 
    # The sign bit is on... so extend it
    ((_value = ( - 0x80 ) | _value ))
  fi
  echo "${_value}"
}


function base2_digits () {
  local digits=0

  [[ $# == 1 ]] || { digits="$(( $1 >> 2))"; shift; }
  local value="$1"
  local hex=$(printf "%0${digits}x" $(( $value )) )

  local bin=
  for (( i = 0 ; i < ${#hex} ; i++ )) ; do
    case ${hex:$i:1} in 
        0)   bin="${bin}0000" ;;
        1)   bin="${bin}0001" ;;
        2)   bin="${bin}0010" ;;
        3)   bin="${bin}0011" ;;
        4)   bin="${bin}0100" ;;
        5)   bin="${bin}0101" ;;
        6)   bin="${bin}0110" ;;
        7)   bin="${bin}0111" ;;
        8)   bin="${bin}1000" ;;
        9)   bin="${bin}1001" ;;
        a|A) bin="${bin}1010" ;;
        b|B) bin="${bin}1011" ;;
        c|C) bin="${bin}1100" ;;
        d|D) bin="${bin}1101" ;;
        e|E) bin="${bin}1110" ;;
        f|F) bin="${bin}1111" ;;
    esac
  done
  echo ${bin}
}

function base2 () {
  for i in "$@" ; do 
    local bin="$(base2_digits $i)"
    printf "0b%s " $bin
  done
  printf "\n"
}

function base8_digits () {
  local digits=0

  [[ $# == 1 ]] || { digits="$1"; shift; }
  local value="$1"

  printf "%0${digits}o" $(( $value ))
}
function base8 () {

  for i in $@ ; do 
    # special case of just 0 --> 00
    printf "0%s " "$(base8_digits $i )"
  done
  printf "\n"
}

function base10_digits () {
  local digits=0

  [[ $# == 1 ]] || { digits="$1"; shift; }
  local value="$1"
  
  printf "% ${digits}d" $(( $value ))
}
function base10 () {

  for i in $@ ; do 
        printf "%s " "$(base10_digits $i )"
  done
  printf "\n"
}

function base16_digits () {
  local value="$1"
  local digits=0

  [[ $# == 1 ]] || { digits="$1"; shift; }
  local value="$1"

  printf "%0${digits}x" $(( $value ))
}
function base16 () {

  for i in $@ ; do 
        printf "0x%s " "$(base16_digits $i )"
  done
  printf "\n"
}


function ascii.index () {
  str="$*"
  for (( i = 0; i < ${#str}; i++ )) ; do 
    local glyph=${str:i:1}
    if [[ ${glyph} == '\' ]] ; then 
      local next=${str:i+1:1}
      ((i ++))
      case $next in 
         0 ) value="0" ;;
         a ) value="7" ;;
         b ) value="8" ;;
         t ) value="9" ;;
         n ) value="10" ;;
         v ) value="11" ;;
         f ) value="12" ;;
         r ) value="13" ;;
         e ) value="27" ;;
         \\ ) value="92" ;;
         * ) value=0xFF ; echo "$next" ;;  # an error
      esac
      printf "%d " "$value"
    else
      printf "%d " "'${glyph}"
    fi
  done
  printf "\n"
}

function ascii.char () {
  for i in $@   ; do 
    if ((  0x20 <= $i && $i <= 0x7e )) ; then 
      printf \\$(printf '%03o' $(( $i )) )
    else
      char=""
      case $i in 
          0) char="\\0" ;;
          7) char="\\a" ;;
          8) char="\\b" ;;
          9) char="\\t" ;;
         10) char="\\n" ;;
         11) char="\\v" ;;
         12) char="\\f" ;;
         13) char="\\r" ;;
         27) char="\\e" ;;
      esac
      echo -n "$char"
    fi
  done
  printf "\n"
}



