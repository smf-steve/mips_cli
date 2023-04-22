#! /bin/bash 

# Note do NOT use comma after position parameters.
#   these parameters may alredy have commas from the
#   users input


function li () {
    synonym_on "li \$$(name $1), \"$2\""
    addiu "$1" $zero "$2"
    synonym_off
}

function move () {
    synonym_on "move \$$(name $1), \$$(name $2)"
    addu $1 $zero "$2"
    synonym_off
}

function nop () {
    synonym_on "nop"
    sll $zero, $zero, 0
    synonym_off
}

