assign_registers_random

add $t1, $t2, $t3
sub $t4, $t5, $t6

addi $t0, $t1, 5
subi $t2, $t3, 5

assign $t1 0x7FFFFFFF  # overflow
addi $t1, $t1, 1

assign $t1 0x80000000  # carry
addi $t1, $t1, -1
