
li $t1, 10
average $t3, $t1, 20
addi $t1, $t1, -1

.macro double %one %two
  add %one, %two, %two
.end_macro

double $s0, $s1


