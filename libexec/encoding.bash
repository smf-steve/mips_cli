#! /bin/bash

function upper() {
    _value=$1
    printf "0x%04x\n" $((  (_value >> 16 ) & 0xFFFF ))
}
function lower() {
    _value=$1
    printf "0x%04x\n" $((  _value & 0xFFFF ))
}


function encode_register () {
   local _reg=$1
   local _code=$(to_binary $(to_hex 2 $_reg))
   local _code=$(sed -e 's/ //g' -e 's/.*\(.....\)$/\1/' <<< "${_code}" )
   echo "${_code}"
}
alias encode_shamt=encode_register

function encode_immediate () {
   local _value=$1
   local _value=$(( $1 & 0xFFFF ))
   local _code=$(to_binary "$(to_hex 4 $_value)")
   sed -e 's/ //g' <<< "${_code}"
}

function encode_offset () {
   local _label="$1"
   local _address=$(lookup_text_label $_label)

   if [[ -z "$_address" ]] ; then 
     echo "_unresolved_"
   else
     local _offset=$((  _address - $(rval $_pc) ))

     if (( _offset > max_immediate || min_immediate > _offset  )) ; then 
       instruction_error "Branch out of reach."
     fi
  
     local _code=$(to_binary "$(to_hex 2 $(( _offset >> 2 )) )" )
     local _code=$(sed -e 's/ //g' -e 's/.*\(.....\)$/\1/' <<< "${_code}" )

     echo "${_code}"
  fi
}

function decode_offset () {
  local _imm="$1"

  echo "$(( _imm + $(rval $_pc)  ))"
}

function encode_address () {
  # PC = PC&0xF0000000 | (addr0<< 2)
  local _label=$1
  local _address=$(lookup_text_label $_label)

  if [[ -z "$_address" ]] ; then 
    echo "_unresolved_"
  else
    local _code=$(to_binary "$(to_hex 7 $(( _address  >> 2 )) )" )
    local _code=$(sed -e 's/ //g'  <<< "${_code}" )
    #ensure the code is no more than 26 bits
    echo "${_code:2}"
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


# New format:  ?
# encode_J_instruction
# print_J_instruction

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

