#! /bin/bash

# This file contains the various functions required to 
# encode an instruction or any of its subcomponents.
#

# lookup_opcode:
# lookup_func:

# encode_register: reg
# decode_register: num
# encode_shamt:  num
# decode_shamt:  bnum

# encode_immediate:
# decode_immediate:
# encode_offset: label [ PC ]
# decode_offset:

# encode_address:
# decode_address:


# print_R_encoding:
# print_I_encoding:
# print_J_encoding:


################################################
# Op Encodings
# Special  00
# Special2 1C
function lookup_opcode () {
    local num="" 
    num=$(eval echo \$op_code_$1)  2>&1 >/dev/null
    if [[ $? == 0 ]] ; then 
      echo $num
    else
      instruction_error "Undefined \"op\""
    fi
}

################################################
# Func Encodings
function lookup_func () {
    local num="" 
    num=$(eval echo \$func_code_$1)  2>&1 >/dev/null
    if [[ $? == 0 ]] ; then
      echo $num
    else
      instruction_error "Undefined \"func\""
    fi 
}

################################################
# Register Encodings
#   - registers are presented as: ${mnemonic}
function decode_register () {
    _reg="$1"
    [[ $_reg > 0 ]] || { input_error "unknown general purpose register" ; return ;  }
    [[ $_reg < 32 ]] || { input_error "unknown general purpose register" ; return ;  }
    echo $_reg
}
function encode_register () {
   local _reg=$1
   local _code=$(base2_digits 8 $_reg )
   echo "${_code:3:5}"
}
alias encode_shamt=encode_register



function encode_immediate () {
   local _value=$(( $1 & 0xFFFF ))
   echo $(base2_digits 16 $_value)
}

function encode_offset () {
   local _label="$1"
   local _offset="$1"
   local _pc_value="$2"
   local _address

   [[ -n _pc_value ]] || _pc_value=$(rval $_pc)

   if [[ ${_label:0:1} =~ [[:alpha:]] ]] ; then
      _address=$(lookup_text_label $_label)
     if [[ -n "$_address" ]] ; then 
         echo "_unresolved_ $_address - \$_pc" 
         return 
     fi
      _offset=$((  _address - _pc_value ))
   fi

   if (( _offset > max_immediate || min_immediate > _offset  )) ; then 
     instruction_error "Branch out of reach."
   fi
  
   local _code=$(base2_digits 16 $(( _offset >> 2 )) )

   echo "${_code}"
   echo "Bug need to check which segment I'm in"
}

function decode_offset () {
  local _imm="$1"

  echo "$(( _imm + $(rval $_pc)  ))"
}

function encode_address () {
  # PC = PC&0xF0000000 | (addr0<< 2)
  local _label=$1
  local _address=$(lookup_text_label $_label)
  local _code

  if [[ -z "$_address" ]] ; then 
    echo "_unresolved_"
  else
    if (( ( _address % 4) != 0 )) ; then
      echo "Invaled address"
    else 
      _code=base2_digits 28 $(( _address  >> 2 )) 
      # Only return 26 bits
      echo ${_code:2}
    fi
  fi
}

function decode_address () {
  local _addr="$1"

  echo "$(( _addr << 2 ))"
}


function print_R_encoding () {
    local _name="$1"
    local _rs="$2"
    local _rt="$3"
    local _rd="$4"
    local _shamt="$5"
    local _rs_name="$(name $_rs)"
    local _rt_name="$(name $_rt)"
    local _rd_name="$(name $_rd)"

    local _op_code="${op_code_REG}"
    local _rs_code="$(encode_register $_rs)"
    local _rt_code="$(encode_register $_rt)"
    local _rd_code="$(encode_register $_rd)"
    local _shamt_code=$(encode_shamt $_shamt)
    local _func_code="$(lookup_func $_name)" 

    local encoding="${_op_code}${_rs_code}${_rt_code}${_rd_code}${_shamt_code}${_func_code}"
    TEXT[$(rval $_pc)]="$encoding"

    [[ ${EMIT_ENCODINGS} == "TRUE" ]] || return

    printf "\t|%-6s|%-5s|%-5s|%-5s|%-5s|%-6s|\n" " op" " rs" " rt" " rd" " sh" " func"
    printf "\t|------|-----|-----|-----|-----|------|\n"
    printf "\t|%-6s|%-5s|%-5s|%-5s|%5s|%-6s|\n" \
           " REG" " \$$_rs_name" " \$$_rt_name" " \$$_rd_name" "$_shamt" " ${_name:0:5}"

    printf "\t|%s|%s|%s|%s|%s|%s|\n" \
           $_op_code $_rs_code $_rt_code $_rd_code $_shamt_code $_func_code
    printf "\n"
}


function print_I_encoding () {
    local _op="$1" 
    local _rs="$2" 
    local _rt="$3"
    local _imm="$4"
    local _label="$5"

    local _rs_name="$(name $_rs)" 
    local _rt_name="$(name $_rt)"
    local _op_code=$(lookup_opcode "$_op") 
    local _rs_code=$(encode_register "$_rs")
    local _rt_code=$(encode_register "$_rt")

    local _imm_code
    if [[ -n "$_label" ]] ; then
       # the immediate is base upon a label
       _imm=$_label
       _imm_code=$(encode_offset $_label)
    else
       _imm_code=$(encode_immediate "$_imm")
    fi


    local encoding="${_op_code}${_rs_code}${_rt_code}${_imm_code}"
    TEXT[$(rval $_pc)]="$encoding"

    [[ ${EMIT_ENCODINGS} == "TRUE" ]] || return



    printf "\t|%-6s|%-5s|%-5s|%-16s|\n" \
            " op" " rs" " rt" " imm"
    printf "\t|------|-----|-----|----------------|\n"

    if [[ -n "$_label" ]] ; then
      printf "\t|%-6s|%-5s|%-5s| %-15s|\n" \
              " ${_op:0:5}" " \$$_rs_name" " \$$_rt_name" "${_label:0:14}"
    else        
      printf "\t|%-6s|%-5s|%-5s|%16s|\n" \
              " ${_op:0:5}" " \$$_rs_name" " \$$_rt_name" "$_imm"
    fi
    if [[ $_imm_code == "_unresolved_" ]] ; then 
        _imm_code="????????????????"   # To center it
    fi

    printf "\t|%s|%s|%s|%16s|\n" \
            "$_op_code" "$_rs_code" "$_rt_code" "$_imm_code"
    printf "\n"
}

function print_J_encoding () {
    local _op="$1"
    local _label="$2"
    local _op_code=$(lookup_opcode $_op) 
    local _addr_code=$(encode_address $_label)

    # If the _addr_code is _unresolved_, perhaps
    # REGISTER[$_ir]="${_op_code}\$(encode_address ${_label})"

    local encoding="${_op_code}${_addr_code}"
    TEXT[$(rval $_pc)]="$encoding"

    [[ ${EMIT_ENCODINGS} == "TRUE" ]] || return


    printf "\t|%-6s|%-26s|\n" " op" " addr"
    printf "\t|------|--------------------------|\n"
    printf "\t| %-5s| %-25s|\n" " ${_op:0:5}" "${_label:0:24}"

    if [[ $_addr_code == "_unresolved_" ]] ; then 
        _addr_code="??????????????????????????"   # To center it
    fi

    printf "\t|%s|%26s|\n" "$_op_code" "$_addr_code"
    printf "\n"
}


function print_string_encoding () {
  local str="$1"

  [[ ${EMIT_ENCODINGS} == "TRUE" ]] || return

  local dec_values=( $(ascii.index "$str") )
  local _size=${#dec_values[@]}
  local hex_values=()

  local index=0
  local hex_value="0"
  for value in "${dec_values[@]}" ; do

    (( hex_value = ( hex_value << 8 ) | value  ))
    (( index ++ ))
    if (( index == 4 )) ; then 
      hex_values+=( $hex_value )
      index=0
      hex_value=0
    fi
  done
  if (( index != 0 )) ; then 
     hex_values+=( $hex_value )
  fi

  if  (( _size <= 4  )) ; then 
    print_memory_encoding ${DATA_LAST} $_size "${hex_values[@]}"
  else
    print_memory_encoding_multiple ${DATA_LAST} $_size "${hex_values[@]}"
  fi
}


function print_word_row () {
   local _start="$1"
   local _size="$2"
   local _value="$3"
   local _end="$4"
   local _text="$5"

   local _dec=${_value}
   local _unsigned=$(( _value & 0xFFFFFFFF ))
   local _hex=$(base16_digits $(( _size << 1)) ${_unsigned} )
   local _bin=$(base2_digits  $(( _size << 3)) ${_unsigned} )
  
   _bin="$(sed -e 's/\(........\)/\1 /g' -e 's/ $//' <<< $_bin)"
   if [[ -z ${_text} ]] ; then 
     _hex=$(group_4_2 $_hex | sed 's/ *$//')
     _text="0x${_hex}"
   fi
   printf "%s %s %s \"%s\"\n"  "${_start}" "${_bin}" "${_end}" "${_text}"

}
function print_memory_encoding_multiple () {
  local _address="$1"
  local _size="$2"  
  local _value="$3" ; shift; shift ; shift

  [[ ${EMIT_ENCODINGS} == "TRUE" ]] || return

  local _indent="                "

  printf "   | address    | value                               |\n" 
  printf "   |------------|-------------------------------------|\n"
  printf "   | 0x%8x " $_address

  print_word_row "|" 4 $_value "/" ""
  (( _size -= 4 ))

  local _values=( "${@}" )
  for (( i=0; i < $# - 1 ; i++ )) ; do 
     print_word_row "${_indent}/" 4 ${_values[$i]} "/" ""
     (( _size -= 4 ))
  done
  local end="|"
  for (( i = _size; i < 4 ; i++ )) ; do
    end="         "$end
  done
  print_word_row "${_indent}/" $(( _size )) ${_values[$#-1]} "$end" ""   #< row size is what is left over

  printf "   | 0x%8x |\n" ${DATA_NEXT}
  echo
}

function print_zero_encoding () {
   local bytes="$1"

   [[ ${EMIT_ENCODINGS} == "TRUE" ]] || return
   local ZEROS=()

   for ((i=0; i < bytes ; i+=4)) ; do
     ZEROS+=( 0x00 )
   done
   if (( bytes <= 4 )) ; then
      print_memory_encoding ${DATA_LAST} $bytes "${ZEROS[@]}"   
   else
      print_memory_encoding_multiple ${DATA_LAST} $bytes "${ZEROS[@]}"
   fi
}

function print_memory_encoding () {
  local _address="$1"
  local _size="$2" 
  local _value="$3"  
  local _text="$4"

  [[ ${EMIT_ENCODINGS} == "TRUE" ]] || return

  local _dashes="--------"   # Eight Dashes: 8 bits
  for (( i = 2 ; i <= $_size ; i++ )) ; do 
    _dashes="${_dashes}---------" # Nine Dashes: 1 space + 8 bits
  done
  local _title="$( sed -e 's/./ /g' -e 's/^...../value/' <<< "$_dashes" )"

  printf "   | address    | %s |\n" "$_title"
  printf "   |------------|-%s-|\n" "$_dashes"
  printf "   | 0x%8x " "${_address}"

  print_word_row "|" $_size $_value "|" "$_text"
  printf "   | 0x%8x |\n" $(( _address + _size ))
  echo
}


## Issues
# 1. if the memory cell is empty -- because it was an aligment thing
# 1. if the char is '
# 1. if the char is [[ -z char]]

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
function print_data_word_little () {
    local address="$1"
    local byte_0=${DATA[ address ]}
    local byte_1=${DATA[ (( address - 1 )) ]}
    local byte_2=${DATA[ (( address - 2 )) ]}
    local byte_3=${DATA[ (( address - 3 )) ]}

    local half_0=$( printf "0x%04x" $(( byte_0 <<  8 | byte_1 )) )
    local half_1=$( printf "0x%04x" $(( byte_2 <<  8 | byte_3 )) )
    local   word=$( printf "0x%08x" $(( half_0 << 16 | half_1 )) )

    printf "$little_pattern" $(( address ))     ""      ""          "${byte_0}" "$(map.ascii ${byte_0})"
    printf "$little_pattern" $(( address - 1 )) ""      "${half_0}" "${byte_1}" "$(map.ascii ${byte_1})"
    printf "$little_pattern" $(( address - 2 )) ""      ""          "${byte_2}" "$(map.ascii ${byte_2})"
    printf "$little_pattern" $(( address - 3 )) ${word} "${half_1}" "${byte_3}" "$(map.ascii ${byte_3})"
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
    printf "$big_pattern" $(( address - 3 )) "$(map.ascii ${byte_3})" "${byte_3}" "${half_1}" ${word} 
}

