#! /bin/bash


################################################
# Op Encodings

# 000 Row
declare -r        op_code_REG='000000'  # 0x00
# declare -r       op_code_xx='000001'  
declare -r          op_code_j='000010'  # 0x02
declare -r        op_code_jal='000011'  # 0x03
declare -r        op_code_beq='000100'  # 0x04
# declare -r      op_code_bne='000101'  
declare -r       op_code_blez='000110'  # 0x06
declare -r       op_code_bgtz='000111'  # 0x07

# 001 Row
declare -r       op_code_addi='001000'  # 0x08
declare -r      op_code_addiu='001001'  # 0x09
declare -r       op_code_slti='001010'  # 0x0A
declare -r      op_code_sltiu='001011'  # 0x0B
declare -r       op_code_andi='001100'  # 0x0C
declare -r        op_code_ori='001101'
declare -r        op_code_xor='001110'
# declare -r       op_code_xx='001111'

# 010 Row
# declare -r       op_code_xx='010000'  # 0x10
# declare -r       op_code_xx='010001'  # 0x11
# declare -r       op_code_xx='010010'  # 0x12
# declare -r       op_code_xx='010011'  # 0x13
# declare -r       op_code_xx='010100'
# declare -r       op_code_xx='010101'
# declare -r       op_code_xx='010110'
# declare -r       op_code_xx='010111'

# 011 Row  # Not sure which version of MIPS, mars does not have these
# declare -r      op_code_llo='011000'  # 0x18
# declare -r      op_code_lhi='011001'  # 0x19
# declare -r     op_code_trap='011010'  # 0x1A
# declare -r       op_code_xx='011011'  # 0x1B
# declare -r       op_code_xx='011100'
# declare -r       op_code_xx='011101'
# declare -r       op_code_xx='011110'
# declare -r       op_code_xx='011111'


# 100 Row
declare -r        op_code_lb='100000'  # 0x20
declare -r        op_code_lh='100001'  # 0x21
#declare -r       op_code_xx='100010'  # 0x22
declare -r        op_code_lw='100011'  # 0x23
declare -r       op_code_lbu='100100'  # 0x24
declare -r      op_code_lbhu='100101'  # 0x25
# declare -r      op_code_xx='100110'  # 0x26
# declare -r      op_code_xx='100111'  # 0x27

# 101 Row
declare -r        op_code_sb='101000'  # 0x28
declare -r        op_code_sh='101001'  # 0x29
# declare -r      op_code_xx='101010'  # 0x2A
declare -r        op_code_sw='101011'  # 0x2B
# declare -r      op_code_xx='101010'
# declare -r      op_code_xx='101011'
# declare -r      op_code_xx='101100'
# declare -r      op_code_xx='101101'
# declare -r      op_code_xx='101110'
# declare -r      op_code_xx='101111'




################################################
# Func Encodings

# 000 Row
declare -r     func_code_sll='000000'  # 0x00
# declare -r    func_code_xx='000001'  
declare -r     func_code_srl='000010'  # 0x02
declare -r     func_code_sra='000011'  # 0x03
declare -r    func_code_sllv='000100'  # 0x04
# declare -r    func_code_xx='000101'  
declare -r    func_code_srlv='000110'  # 0x06
declare -r    func_code_srav='000111'  # 0x07

# 001 Row
declare -r      func_code_jr='001000'  # 0x08
declare -r    func_code_jalr='001001'  # 0x09
declare -r    func_code_movz='001010'  # 0x0A
declare -r    func_code_movn='001011'  # 0x0B
declare -r func_code_syscall='001100'  # 0x0C
# declare -r    func_code_xx='001101'
# declare -r    func_code_xx='001110'
# declare -r    func_code_xx='001111'

# 010 Row
declare -r    func_code_mfhi='010000'  # 0x10
declare -r    func_code_mthi='010001'  # 0x11
declare -r    func_code_mflo='010010'  # 0x12
declare -r    func_code_mtlo='010011'  # 0x13
# declare -r    func_code_xx='010100'
# declare -r    func_code_xx='010101'
# declare -r    func_code_xx='010110'
# declare -r    func_code_xx='010111'

# 011 Row
declare -r    func_code_mult='011000'  # 0x18
declare -r   func_code_multu='011001'  # 0x19
declare -r     func_code_div='011010'  # 0x1A
declare -r    func_code_divu='011011'  # 0x1B
# declare -r    func_code_xx='011100'
# declare -r    func_code_xx='011101'
# declare -r    func_code_xx='011110'
# declare -r    func_code_xx='011111'


# 100 Row
declare -r     func_code_add='100000'  # 0x20
declare -r    func_code_addu='100001'  # 0x21
declare -r     func_code_sub='100010'  # 0x22
declare -r    func_code_subu='100011'  # 0x23
declare -r     func_code_and='100100'  # 0x24
declare -r      func_code_or='100101'  # 0x25
declare -r     func_code_xor='100110'  # 0x26
declare -r     func_code_nor='100111'  # 0x27

# 101 Row
# declare -r    func_code_xx='101000'
# declare -r    func_code_xx='101001'
declare -r     func_code_stl='101010'  # 0x2A
declare -r    func_code_sltu='101011'  # 0x2B
# declare -r    func_code_xx='101010'
# declare -r    func_code_xx='101011'
# declare -r    func_code_xx='101100'
# declare -r    func_code_xx='101101'
# declare -r    func_code_xx='101110'
# declare -r    func_code_xx='101111'



function lookup_func () {
    local num="" 
    num=$(eval func_code_$1)  2>&1 >/dev/null
    if [[ $? == 0 ]] ; then
      echo $num
    else
      error "Undefined \"func\""
    fi 
}




# Special  00
# Special2 1C
function lookup_code () {
    num=""
    #lias op_code_add 2> /dev/null
    if [[ $? == 0 ]] ; then 
      num=$(eval op_code_$1)
      sed 's/ //g' <<< $(to_binary ${num}) 
    fi
}


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
    _name="$1"
    _op_code="${special}"

    _rs_code=$(to_binary "$(to_hex 8 $2)")
    _rt_code=$(to_binary "$(to_hex 8 $3)")
    _rd_code=$(to_binary "$(to_hex 8 $4)")
      sed -e 's/ //g' -e 's/.*\(......\)$/\1/' <<< $(to_binary ${num})
    _shamt=$(to_binary  5)
    _func_code="$(lookup_func $1)" 


	printf "| op | rs | rt | rd | shamt | func |\n"
    printf "| %s | %s | %s | %s | %s    | %s |\n", \
           $_special, $rs_code, rt_code, $_rd_code, $_func

}

function print_I_encoding () {
    _op=$(lookup_code $1) 
    _rs_code=$(register_code $2)
    _rt_code=$(register_code $3)
    _imm=$(func_code_offset $4)

    printf "| op | rs | rt |    imm  |"
    printf "| %s | %s | %s | %s | %s |\n", \
            $_op, $rs_code, rt_code, $_imm

}

function func_code_address () {
     label=$1
     label="echo $(( 0x04000000))"

     address=$(( $label >> 2 ))
     code=$(to_binary "$(to_hex 8 $address)")
     echo $code
}

function print_J_encoding () {
    _op=$(lookup_code $1) 
    _addr=$(func_code_address $2)

    printf "| op |       addr     |\n"
    printf "| %s | %s | \n" "$_op" "$_addr"
  
}

