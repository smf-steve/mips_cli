#################################################################################
# This ".s" file is used to generate all of the pseudo instructions into the
# MIPS environment.
#################################################################################


        .include "${MIPS_CLI_HOME}/libexec/instructions/pseudo/bitwise.s"
        .include "${MIPS_CLI_HOME}/libexec/instructions/pseudo/branch.s"
        .include "${MIPS_CLI_HOME}/libexec/instructions/pseudo/general.s"
        .include "${MIPS_CLI_HOME}/libexec/instructions/pseudo/math.s"
        .include "${MIPS_CLI_HOME}/libexec/instructions/pseudo/set.s"
