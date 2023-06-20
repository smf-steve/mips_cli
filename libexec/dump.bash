#! /bin/bash

function dump_core () {
	local _filename="$1"
	local core_file="${_filename}.core"
	 
	cat > ${core_file} <<- EOF 

	# Symbol Table
	$(dump_symbol_table)
	# ------------

	# Instruction Table
	$(dump_instructions)
	# ------------

	# Text Segment
	$(dump_segment TEXT)
	# ------------

	# Data Segment
	$(dump_segment DATA)
	# ------------

	# Heap Segment
	$(dump_segment HEAP)
	# ------------

	# Stack Segment
	$(dump_segment STACK)
	# ------------

	# Registers
	$(dump_registers)
	# ------------

EOF
}

function dump_symbol_table () {

	cat <<- EOF
	## Data Labels
	$(declare -p | grep ^data_label)

	## Text Labels
	$(declare -p | grep ^label_label)

EOF
}

alias dump_instructions="dump_segment INSTRUCTION"
function dump_segment  () {
	local segment="$1" 
	local raw="$2"

	[[ "$raw" == "TRUE" ]] ||  echo  "declare -a ${segment}=("
	for key in $( eval echo \${!${segment}[@]} ) ; do
		 [[ "$raw" == "TRUE" ]] || printf " [0x%x]=" "${key}"
		 eval echo \\\"\${${segment}[${key}]}\\\" 
	done
	[[ "$raw" == "TRUE" ]] || echo ")"
	echo
}

# dump_registers:
# for readability, perhaps the putput should be
#  [$t1]="value"
function dump_registers () {
	local segment="$1" 
	local raw="$2"

	[[ "$raw" == "TRUE" ]] ||  echo  "declare -a REGISTER=("
	for key in ${!REGISTER[@]} ; do
		 [[ "$raw" == "TRUE" ]] || printf " [\$$(name ${key})]="
		 echo \"${REGISTER[${key}]}\"
	done
	[[ "$raw" == "TRUE" ]] || echo ")"
	echo
}

