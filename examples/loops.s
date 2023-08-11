        .text

        li $t1, 4
        li $t2, 0
a:      addi $t2, $t2, 1    # Backwards loop
        bne  $t1, $t2, a
        nop
@print_register $t2   # value should be 4

        li $t2, 0
b:      beq $t1, $t2, c      # Forward loop
          addi $t2, $t2, 1 
        beq $zero, $zero, b
c:      nop
@print_register $t2  # value should be 4