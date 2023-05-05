#! /bin/bash 


function sub_execute () {
   echo "  ${@}"
   eval "${@}"
}

function subi() {
    echo "Pseudo instruction for:"
    sub_execute addi \$at, \$zero, \$$(name $3)
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

