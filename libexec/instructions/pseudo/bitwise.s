.pseudo rol %dst, %src, %imm          # Rotate left
    srl $at, %src, $(( 32 - %imm))
    sll %dst, %src, %imm   
    or  %dst, %dst, $at
.end_pseudo

.pseudo rolv %dst, %src1, %src2       # Rotate left with a registers
    subu $at, $zero, %src2
    srlv $at, %src1, $at    
    sllv %dst, %src1, %src2  
    or %dst, %rdst, $at
.end_pseudo

.pseudo ror %dst, %src, %imm          # Rotate right
    sll $at, %src, $(( 32 - %imm))     
    srl %dst, %src, %imm
    or  %dst, %dst, $at 
.end_pseudo

.pseudo ror %dst, %src1, %src2         # Rotate right with a register
    subu $at, $zero, %src2
    sllv $at, %src1, $at    
    srlv %dst, %src1, %src2  
    or %dst, %dst, $at
.end_pseudo