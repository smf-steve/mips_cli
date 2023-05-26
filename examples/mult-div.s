assign_registers_random

mthi  $t1
mtlo  $t2
mfhi  $t3
mflo  $t4

assign $t1 25
assign $t2 5

mult $t1, $t2
div  $t1, $t2

assign $t1 0xFFFFFFFF
assign $t2 0xFFFFFFFF

mult $t1, $t2
div  $t1, $t2

