
#
.pseudo rol %dst, %src, %imm    # Rotate left
    srl $at, %src, $(( 32 - %imm))
    sll %dst, %src, %imm   
    or  %dst, %dst, $at
.end_pseudo


.pseudo rolv %rdst, %rsrc1, %rsrc2    # Rotate left
    subu $at, $zero, %rsrc2
    srlv $at, %rsrc1, $at    
    sllv %rdst, %rsrc1, %rsrc2  
    or %rdst, %rdst, $at
.end_pseudo

#
.pseudo ror %dst, %src, %imm    # Rotate right
    sll $at, %rsrc, $(( 32 - %imm))     
    srl %dst, %src, %imm
    or  %dst, %dst, $at 
.end_pseudo

