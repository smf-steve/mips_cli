#! /bin/bash 


function sub_execute () {
   echo "  ${@}"
   eval "${@}"
}

function upper() {
    _label=$1
    eval _value=${label_data_}${_label}
    echo $((  (_value >> 16 ) & 0xFFFFFFFF ))
}
function lower() {
    _label=$1

    eval _value=${label_data_}${_label}
    echo $((  _value & 0xFFFFFFFF ))
}
function la() {
    echo "Address of A is: $((eval _value=${label_data_}${2}))"
    echo "Pseudo instruction for:"
    sub_execute lui \$at, upper($2)
    sub_execute ori \$$(name $1), \$at, lower($2)
    pseudo_off
}


function subi() {
    echo "Pseudo instruction for:"
    sub_execute addi \$at, \$zero, $3
    sub_execute sub \$$(name $1), \$$(name $2), \$at          
    pseudo_off
}


function rem () {
    echo "Pseudo instruction for:"
    sub_execute div \$$(name $2), \$$(name $3)
    sub_execute mfhi \$$(name $1)
    pseudo_off
}

function mul () {
    echo "Pseudo instruction for:"
    sub_execute mult \$$(name $2), \$$(name $3)
    sub_execute mflo \$$(name $1)
    pseudo_off
}

