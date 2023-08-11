        .text

        .macro average %some, %two, %his
            add  %some, %two, %his
            srl  %some, %some, 1
        .end_macro
        
        .macro double %one %two
           add %one, %two, %two
        .end_macro
        
        li $t1, 10
        li $s0, 20
        average $t3, $t1, $s0
@echo "$(rval $t3) == 15"
        
        li $s1, 20
        double $s0, $s1
@echo "$(rval $s0) = 40"
