#! /bin/bash

function lookup_func () {
    num=""
    alias func_code_$1 2>/dev/null
    if [[ $? == 0 ]] ; then
      num=$(eval func_code_$1)
      sed -e 's/ //g' -e 's/.*\(......\)$/\1/' <<< $(to_binary ${num})
    fi
}
#These are hex numbers.
alias func_code_sll="echo 0"
alias func_code_srl="echo 2"
alias func_code_sra="echo 3"
alias func_code_sllv="echo 4"
alias func_code_srlv="echo 6"
alias func_code_srav="echo 7"
alias func_code_jr="echo 8"
alias func_code_jalr="echo 9"
alias func_code_movz="echo A"
alias func_code_movn="echo B"
alias func_code_syscall="echo C"
alias func_code_mfhi="echo 10"
alias func_code_mthi="echo 11"
alias func_code_mflo="echo 12"
alias func_code_mtlo="echo 13"
alias func_code_mult="echo 18"
alias func_code_multu="echo 19"
alias func_code_div="echo 1A"
alias func_code_add="echo 20"
alias func_code_addu="echo 21"
alias func_code_sub="echo 22"
alias func_code_subu="echo 23"
alias func_code_and="echo 24"
alias func_code_or="echo 25"
alias func_code_xor="echo 26"
alias func_code_nor="echo 27"
alias func_code_slt="echo 2A"
alias func_code_sltu="echo 2B"

# Special  00
# Special2 1C
function lookup_code () {
    num=""
    alias op_code_add 2> /dev/null
    if [[ $? == 0 ]] ; then 
      num=$(eval op_code_$1)
      sed 's/ //g' <<< $(to_binary ${num}) 
    fi
}


alias op_code_j="echo 2"
alias op_code_jal="echo 3"
alias op_code_beq="echo 4"
alias op_code_bne="echo 5"
alias op_code_blez="echo 6"
alias op_code_bgtz="echo 7"
alias op_code_addi="echo 8"
alias op_code_addiu="echo 9"
alias op_code_slti="echo A"
alias op_code_sltiu="echo B"
alias op_code_andi="echo C"
alias op_code_ori="echo D"
alias op_code_xori="echo E"
alias op_code_lui="echo F"
alias op_code_beql="echo 14"
alias op_code_bnel="echo 15"
alias op_code_blezl="echo 16"
alias op_code_bgtzl="echo 17"
alias op_code_lb="echo 20"
alias op_code_lh="echo 21"
alias op_code_lw="echo 23"
alias op_code_sb="echo 28"
alias op_code_sh="echo 29"
alias op_code_sw="echo 2A"
alias op_code_ll="echo 30"
alias op_code_sc="echo 38"


function lookup_reg_code () {
	# Convert the number to binary, and then remove the spaces
	sed  's/...\(.\) /\1/g' <<< $(to_binary $(to_hex 2 $1))
}

function bin_encoding () {
    _hex_value="$1"
    _num_bits="$2"

    _bin_value=$(to_binary $_hex_value} )
    
}

function print_R_encoding () {
	_operation=$1
      _func_code=$(lookup_func $1) 
      if [[ -z "$_func_code"  ]] ; then 
         _op_code=$(lookup_code $1)
      else
         _op_code=${special}
      fi

    _rs_code=$(to_binary "$(to_hex 8 $2)")
    _rt_code=$(to_binary "$(to_hex 8 $3)")
    _rd_code=$(to_binary "$(to_hex 8 $4)")

      sed -e 's/ //g' -e 's/.*\(......\)$/\1/' <<< $(to_binary ${num})
    _shamt=$(to_binary  5)


	printf "| op | rs | rt | rd | shamt | func |\n"
    printf "| %s | %s | %s | %s | %s    | %s |\n", \
           $_special, $rs_code, rt_code, $_rd_code, $_func

}

function print_I_encoding () {
    _op=$(lookup_code $1) 
    _rs_code=$(register_code $2)
    _rt_code=$(register_code $3)
    _imm=$(encode_offset $4)

    printf "| op | rs | rt |    imm  |"
    printf "| %s | %s | %s | %s | %s |\n", \
            $_op, $rs_code, rt_code, $_imm

}

function encode_address () {
     label=$1
     label="echo $(( 0x04000000))"

     address=$(( $label >> 2 ))
     code=$(to_binary "$(to_hex 8 $address)")
     echo $code
}

function print_J_encoding () {
    _op=$(lookup_code $1) 
    _addr=$(encode_address $2)

    printf "| op |       addr     |\n"
    printf "| %s | %s | \n" "$_op" "$_addr"
  
}

