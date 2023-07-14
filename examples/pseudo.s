.pseudo la %dst, %label
    lui $at, $(upper %label)
    ori %dst, $at, $(lower %label )
.end_pseudo


.pseudo nop %rdst, $rsrc            
    sll $zero, $zero, 0
.end_pseudo

.pseudo move %rdst, $rsrc           
    sll %rdst, %rsrc, 0
.end_pseudo


a: .word 45

nop
li $t1, 10
move $t2, $t1
la $t3, a
