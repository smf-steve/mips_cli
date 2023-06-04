
assign $t1 0xFFFFFFFF  # largest number
srl $t2, $t1, 1     #0x7FFFFFF 
sra $t2, $t1, 1     #0xFFFFFFF, -1

sll $t2, $t1, 1     # no Carry
sla $t2, $t1, 1     # Error

sll $t4, $t5, 4 
srl $t5, $t6, 4
sra $t7, $t8, 4


li $at 1
srlv $t2, $t1, $at  #0x7FFFFFF   
srav $t2, $t1, $at  #0xFFFFFFF, -1

li $at 35       # value is to high 
sllv $t5, $t2, $at
srlv $t1, $t3, $at
srav $t5, $t2, $at

li $at 35       # value is to low
sllv $t5, $t2, $at
srlv $t1, $t3, $at
srav $t5, $t2, $at

