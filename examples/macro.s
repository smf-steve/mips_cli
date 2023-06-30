
.macro average %some, %two, %his
    add  %some, %two, %his
    srl  %some, $s0, 1
.end_macro

.macro double %one %two
  add %one, %two, %two
.end_macro

li $t1, 10
average $t3, $t1, 20
addi $t1, $t1, -1

double $s0, $s1
