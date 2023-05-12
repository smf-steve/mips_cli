add $t1, $t2, $t3
sub $t4, $t5, $t6
and $t7, $t8, $t9
or  $s0, $s1, $s2
xor $s3, $s4, $s5
nor $s6, $s7, $gp

addi $t0, $t1, 5
subi $t2, $t3, 5

assign $t1 0x7FFFFFFFFF  # overflow
addi $t1, $t1, 1

assign $t1 0x8000000000  # overflow
addi $t1, $t1, 1


assign $t1 0xFFFFFFFFFF  # largest number
srl $t2, $t1, 1     #0x7FFFFFFFF 
sra $t2, $t1, 1     #0xFFFFFFFFF, -1

li $at, 1
srlv $t2, $t1, $at  #0x7FFFFFFFF   
srav $t2, $t1, $at  #0xFFFFFFFFF, -1

sll $t2, $t1, 1     # no Carry
sla $t2, $t1, $at   # no Carry

sll $t4, $t5, 2
srl $t5, $t6, 3
sra $t7, $t8, 1
sllv $t5, $t2, $t4
srlv $t1, $t3, $t4
srav $t5, $t2, $t4


andi $s0, $s1, 4
 ori $s3, $s4, 6
xori $s6, $s7, 8
nori $t5, $t2, $zero   # invalid

mthi  $t1
mtlo  $t2
mfhi  $t3
mflo  $t4

mult $t1, $t3
div $t5, $t2
