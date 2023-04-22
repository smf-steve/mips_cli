#! /bin/bash 

# Note do NOT use comma after position parameters.
#   these parameters may alredy have commas from the
#   users input

# Echo the pre-echo the command for the correct output
#echo ${CMD_INDENT}${_cmd} \$$(name $_dst), \$$(name $_src1)

function li () {
    synonym_on "li \$$(name $1) \"$2\""
    echo add \$$(name $1) "$2" \$zero
    addiu $1 "$2" $zero
    synonym_off
}

function lui () {
    psuedo_on $1 $2
    addu $at, $2 $zero
    sll  $1 $at, 16
    psuedo_off
}


function nop () {
    synonym_on $1
    sll $zero, $zero, $zero
    synonym_off
}


function subi() {
    pseudo_on $1 $2 $3
    addi $at, $zero, $3
    sub $1 $2 $at          # don't use commas
    pseudo_off
}

function rem () {
    pseudo_on $1 $2 $3
    mul $2 $3 
    mflo $1
    pseudo_off
}

function mult () {
    pseudo_on $1 $2 $ 3
    mul $2 $3 
    mfhi $1
    pseudo_off
}

