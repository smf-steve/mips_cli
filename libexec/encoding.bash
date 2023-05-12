#! /bin/bash


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
      error "Undefined \"op\""
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
      error "Undefined \"func\""
    fi 
}

function encode_register () {
   local _reg=$1
   local _code=$(to_binary $(to_hex 2 $_reg))
   local _code=$(sed -e 's/ //g' -e 's/.*\(.....\)$/\1/' <<< $_code )
   echo $_code
}
alias encode_shamt=encode_register

function encode_immediate () {
   local _value=$1
   local _value=$(( $1 & 0xFFFF ))
   local _code=$(to_binary "$(to_hex 4 $_value)")
   sed -e 's/ //g' <<< $_code 
}

function encode_address () {
     local _label=$1
     #local label="echo $(( 0x04000000))"
     local _address=$(( $label >> 2 ))
     echo $(to_binary "$(to_hex 8 $_address)")
}

emit_encodings=TRUE
function print_R_encoding () {
    [[ ${emit_encodings} == "TRUE" ]] || return

    local _name="$1"
    local _op_code="${op_code_REG}"
    local _rs_code="$(encode_register $2)"
    local _rt_code="$(encode_register $3)"
    local _rd_code="$(encode_register $4)"
    local _shamt=$(encode_shamt $5)
    local _func_code="$(lookup_func $1)" 

    printf "\t|%6s|%5s|%5s|%5s|%5s|%6s|\n" "op" "rs" "rt" "rd" "shamt" "func"
    printf "\t|%s|%s|%s|%s|%s|%s|\n" \
           $_op_code $_rs_code $_rt_code $_rd_code $_shamt $_func_code
    printf "\n"
}

function print_I_encoding () {
    [[ ${emit_encodings} == "TRUE" ]] || return

    local _op=$(lookup_opcode $1) 
    local _rs_code=$(encode_register $2)
    local _rt_code=$(encode_register $3)
    local _imm=$(encode_immediate $4)

    printf "\t|%6s|%5s|%5s|%16s|\n" \
            "op" "rs" "rt" "imm"
    printf "\t|%s|%s|%s|%s|\n" \
            $_op $_rs_code $_rt_code $_imm
    printf "\n"
}

function print_J_encoding () {
    [[ ${emit_encodings} == "TRUE" ]] || return

    _op=$(lookup_opcode $1) 
    _addr=$(encode_address $2)

    printf "\t|%6s|%16s|\n" "op" "addr"
    printf "\t|%s|%s|\n" "$_op" "$_addr"
    printf "\n"
}

