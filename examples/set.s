li $t2, 8
li $t3, 9

slt    $t1, $t2, $t3  # t1 := 1
slt    $t1, $t3, $t2  # t1 := 0
slt    $t1, $t2, $t2  # t1 := 0

li $t2, -8
li $t3, -6
sltu   $t1, $t2, $t3  # t1 := 1
sltu   $t1, $t3, $t2  # t1 := 0


li $t2, 6
slti   $t1, $t2, 5    # t1 := 0
slti   $t1, $t2, 7    # t1 := 1

li $t2, -6
sltiu  $t1, $t2, -5   # t1 := 0
sltiu  $t1, $t2, -7   # t1 := 1

