add $t1, $t2, $t3
sub $t4, $t5, $t6
and $t7, $t8, $t9
or  $s0, $s1, $s2
xor $s3, $s4, $s5
nor $s6, $s7, $gp

addi $t0, $t1, 5
subi $t2, $t3, 5

sll $t4, $t5, 2
srl $t5, $t6, 3
sra $t7, $t8, 1
sllv $t5, $t2, $4
srlv $t1, $t3, $t4
srav $t5, $t2, $t4


andi $s0, $s1, $s2
 ori $s3, $s4, $s5
xori $s6, $s7, $s8
nori $t5, $t2, $zero   # invalid

mthi  $t1
mtlo  $t2
mfhi  $t3
mflo  $t4

mul $t1, $t3
div $t5, $t2
