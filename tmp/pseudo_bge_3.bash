alias bge="prefetch_macro bge"

function pseudo_bge_3  () {
    
  # remove optional commas
  # quote arg that contains a space
  local arg1="$(sed -e 's/,$//' -e 's/\(.* .*\)/1/' <<< $1)"
  local arg2="$(sed -e 's/,$//' -e 's/\(.* .*\)/1/' <<< $2)"
  local arg3="$(sed -e 's/,$//' -e 's/\(.* .*\)/1/' <<< $3)"

  # apply the subsitution from longest to shortest
  # for now, just first to last
  cat <<-EOF |\
    sed -e "s/%src1/$arg1/g" \
        -e "s/%src2/$arg2/g" \
        -e "s/%label/$arg3/g" \

  slt \$at, %src1, %src2
  beq \$at, \$zero, %label
EOF
}
