
.pseudo b %label                    
    beq $zero, $zero, %label
.end_pseudo


.pseudo bge %src1, %src2, %label
    slt $at, %src1, %src2
    beq $at, $zero, %label     
.end_pseudo

.pseudo bgt %src1, %src2, %label
    slt $at, %src2, %src1
    bne $at, $zero, %label     
.end_pseudo

.pseudo ble %src1, %src2, %label
    slt $at, %src2, %src1
    beq $at, $zero, %label     
.end_pseudo

.pseudo blt %src1, %src2, %label
    slt $at, %src1, %src2
    bne $at, $zero, %label     
.end_pseudo


.pseudo bgeu %src1, %src2, %label
    sltu $at, %src1 %src2  
    beq  $at, $zero, %label
.end_pseudo

.pseudo bgtu %src1, %src2, %label
    sltu $at, %src2 %src1  
    bne  $at, $zero, %label
.end_pseudo

.pseudo bleu %src1, %src2, %label
    sltu $at, %src2 %src1  
    beq  $at, $zero, %label
.end_pseudo

.pseudo bltu %src1, %src2, %label
    sltu $at, %src1 %src2  
    bne  $at, $zero, %label
.end_pseudo


