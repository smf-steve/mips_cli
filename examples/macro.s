
li $t1, 10
average $t3, $t1, 20
addi $t1, $t1, -1

.macro double %one %two
  add %one, %two, %two
.end_macro

double $s0, $s1


# Note that when 
#  (top) double $s0, $s1
#  Start of macro "double" ()
#
# This is because PC and TEXT_NEXT are equal
#
# Where as when
# (step) double $s0, $s1
# ... all is good
#
# This is because PC + 4 and TEXT_NEXT are equal
# top:  the machine is NOT executing
# step: the machine is executing

