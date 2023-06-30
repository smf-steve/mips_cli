
.pseudo b %label                    
    beq $zero, $zero, %label
.end_pseudo


.pseudo bge %src1, %src2, %label
    slt $at, %src1, %src2
    beq $at, $zero, %label     #   Branch if Greater or Equal : Branch to statement at label if $t1 is greater or equal to $t2
.end_pseudo

.pseudo bgt %src1, %src2, %label
    slt $at, %src2, %src1
    bne $at, $zero, %label     #   Branch if Greater Than : Branch to statement at label if $t1 is greater than $t2
.end_pseudo

.pseudo ble %src1, %src2, %label
    slt $at, %src2, %src1
    beq $at, $zero, %label     #   Branch if Less or Equal : Branch to statement at label if $t1 is less than or equal to $t2
.end_pseudo

.pseudo blt %src1, %src2, %label
    slt $at, %src1, %src2
    bne $at, $zero, %label     #   Branch if Less Than : Branch to statement at label if $t1 is less than $t2
.end_pseudo


bgeu $t1,$t2,label  sltu $1, RG1, RG2   beq $1, $0, LAB #Branch if Greater or Equal Unsigned : Branch to statement at label if $t1 is greater or equal to $t2 (unsigned compare)
bgtu $t1,$t2,label  sltu $1, RG2, RG1   bne $1, $0, LAB #Branch if Greater Than Unsigned: Branch to statement at label if $t1 is greater than $t2 (unsigned compare)
bleu $t1,$t2,label  sltu $1, RG2, RG1   beq $1, $0, LAB #Branch if Less or Equal Unsigned : Branch to statement at label if $t1 is less than or equal to $t2 (unsigned compare)

bltu $t1,$t2,label  sltu $1, RG1, RG2   bne $1, $0, LAB #Branch if Less Than Unsigned : Branch to statement at label if $t1 is less than $t2

