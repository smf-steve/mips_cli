        .text
@assign_registers_random

        mthi  $t1
        mtlo  $t2
        mfhi  $t3
        mflo  $t4
        
        li $t1 25
        li $t2 5
        
        mult $t1, $t2
        #div  $t1, $t2    ## now in error because of count...
        
        assign $t1 0xFFFFFFFF
        assign $t2 0xFFFFFFFF
        
        mult $t1, $t2   ## Max -1:  -1 * -1 = 1  :==  00000001
        #div  $t1, $t2
        
        multu $t1, $t2  ## Max 0xffffffff:  0xffffffff * 0xffffffff = 0xfffffffe, 00000001
        #divu  $t1, $t2
