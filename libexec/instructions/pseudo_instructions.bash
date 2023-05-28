#! /bin/bash 


function sub_execute () {
   echo "  ${@}"
   eval "${@}"
}

function upper() {
    _value=$1
    printf "0x%04x\n" $((  (_value >> 16 ) & 0xFFFF ))
}
function lower() {
    _value=$1
    printf "0x%04x\n" $((  _value & 0xFFFF ))
}
function la() {
    _address=$(eval echo \$data_label_${2})
    _lower=$(lower $_address)
    _upper=$(upper $_address)

    printf "Address of %s is: 0x%x\n" ${2} $_address
    echo "Pseudo instruction for:"
    sub_execute lui \$at, $_upper
    sub_execute ori \$$(name $1), \$at, $_lower
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

