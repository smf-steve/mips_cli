#################################################################################
# This file contains the set-related pseudo instructions
#
#  seq  ==
#  sne  !=
#  sge  >=
#  sgt  >
#  sle  <=
#  slt  <    (native instruction)
#################################################################################


.pseudo seq %dst, %src1, %src2        # %dst = (%src1 == %src2)? 1 : 0;
        nop     # Not Implemented
.end_pseudo

.pseudo sne %rdst, src1, %src2        # %dst = (%src1 != %src2)? 1 : 0;
        nop     # Not Implemented
.end_pseudo

.pseudo sge %dst, %src1, %src2        # %dst = (%src1 >= %src2)? 1 : 0;
        nop     # Not Implemented
.end_pseudo

.pseudo sgeu %dst, %src1, %src2       # %dst = (%src1 >= %src2)? 1 : 0;
        nop     # Not Implemented
.end_pseudo

.pseudo sgt %rdst, %src1, %src2       # %dst = (%src1 > %src2)? 1 : 0;
        nop     # Not Implemented
.end_pseudo

.pseudo sgtu %rdst, %src1, %src2      # %dst = (%src1 > %src2)? 1 : 0;
        nop     # Not Implemented
.end_pseudo

.pseudo sle %rdst, %src1, %src2       # %dst = (%src1 <= %src2)? 1 : 0;
        nop     # Not Implemented
.end_pseudo

.pseudo sleu %rdst, %src1, %src2      # %dst = (%src1 <= %src2)? 1 : 0;
        nop     # Not Implemented
.end_pseudo

#.native slt %rdst, %src1, %src2       # %dst = (%src1 < %src2)? 1 : 0;
#.native sltu %rdst, %src1, %src2      # %dst = (%src1 < %src2)? 1 : 0;
