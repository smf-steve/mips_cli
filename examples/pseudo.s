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



