
#
.pseudo rol %rdst, %rsrc1, %rsrc2    # Rotate left
    srl $1, %rsrc1, $(( 32 - %imm))
    sll %rdst, %rsrc1, %imm   
    or %rdst, %rdst, $1
.end_psuedo


.pseudo rolv %rdst, %rsrc1, %rsrc2    # Rotate left
    subu $at, $0, %rsrc2
    srlv $at, %rsrc1, $at    
    sllv %rdst, %rsrc1, %rsrc2  
    or %rdst, %rdst, $at
.end_pseudo

#
.pseudeo ror %rdst, %rsrc1, %imm    # Rotate right
    sll $1, %rsrc1, $(( 32 - %imm))     
    srl %rdst, %rsrc1, %imm
    or %rdst, %rdst, $1 
.end_pseudo

