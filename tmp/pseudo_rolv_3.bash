alias rolv="prefetch_macro rolv"

function pseudo_rolv_3  () {
    
  # remove optional commas
  # quote arg that contains a space
  local arg1="$(sed -e 's/,$//' -e 's/\(.* .*\)/1/' <<< $1)"
  local arg2="$(sed -e 's/,$//' -e 's/\(.* .*\)/1/' <<< $2)"
  local arg3="$(sed -e 's/,$//' -e 's/\(.* .*\)/1/' <<< $3)"

  # apply the subsitution from longest to shortest
  # for now, just first to last
  cat <<-EOF |\
    sed -e "s/%dst/$arg1/g" \
        -e "s/%src1/$arg2/g" \
        -e "s/%src2/$arg3/g" \

  subu \$at, \$zero, %src2
  srlv \$at, %src1, \$at
  sllv %dst, %src1, %src2
  or %dst, %rdst, \$at
EOF
}
