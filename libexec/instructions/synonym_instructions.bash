#! /bin/bash 

# Note do NOT use comma after position parameters.
#   these parameters may alredy have commas from the
#   users input

function synonym_on () {
  printf "$1 # is a synonym for: "
}
function synonym_off () {
  :
}

function li () {
    _dst="$(name $(sed 's/,$//' <<< $1 ))"
    _src="$2"
    _text="$(sed 's/ //g' <<< $2 )"

    [[ $_src != $_text ]] && _text="\"$_src\""
    
    echo "Synonym for: addi \$$_dst, \$zero, $_text"
    eval addiu "\$$_dst", $zero, "$_src"
}

function move () {
    _dst="$(name $(sed 's/,$//' <<< $1 ))"
    _src="$(name $2)"
    
    echo "Synonym for: addu \$$_dst, \$zero, \$$_src"
    addu $_dst, $zero, "$_src"
    synonym_off
}

function nop () {
    echo "Synonym for: ssl \$zero, \$zero, 0"
    sll $zero, $zero, 0
}

