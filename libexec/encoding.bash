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



function print_memory_value () {
  local _address="$1"
  local _size="$2"   

  data_memory_read $_size $_address   #This ensure ENDIANESS is address
  local _rval=$(rval $_mbr)


  local _dec=${_rval}
  local _unsigned=$(( _rval & 0xFFFFFFFF ))
  local _hex=$(base16_digits $(( _size << 1)) ${_unsigned} )
  local _bin=$(base2_digits  $(( _size << 3)) ${_unsigned})

  local _dash="$( sed -e 's/./-/g' <<< $_bin )"
  local _value="$( sed -e 's/./ /g' -e 's/^...../value/' <<< $_bin )"

  # Need to deal with big versers Little Endian
  printf "   | address    | %s |\n" "$_value"
  printf "   |------------|-%s-|\n" "$_dash"
  printf "   | 0x%8x | %s | \"0x%s\""  \
        "${_address}" "${_bin}" "${_hex}"
  printf "\n"
}
