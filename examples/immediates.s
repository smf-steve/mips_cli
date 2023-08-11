        .text

        # Native Instructions
        addi $t1, $zero, 2
        addi $t2, $zero, -1
        addi $t3, $zero, 2#10101010
        addi $t4, $zero, "2#101 100"
        addi $t5, $zero, "-2#101 100"
        addi $t6, $zero, 034
        addi $t7, $zero, 0x034
        addi $t8, $zero, -0x034
        addi $t9, $zero, ~0x034
        
        # Pseudo Instructions
        li $t1, 2
        li $t2, -1
        li $t3, 2#10101010
        li $t4, "2#101 100"
        li $t5, "-2#101 100"
        li $t6, 034
        li $t7, 0x034
        li $t8, -0x034
        li $t9, ~0x034
