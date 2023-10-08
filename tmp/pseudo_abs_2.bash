alias abs="prefetch_macro abs"

function pseudo_abs_2  () {
    
  # remove optional commas
  # quote arg that contains a space
  local arg1="$(sed -e 's/,$//' -e 's/\(.* .*\)/1/' <<< $1)"
  local arg2="$(sed -e 's/,$//' -e 's/\(.* .*\)/1/' <<< $2)"

  # apply the subsitution from longest to shortest
  # for now, just first to last
  cat <<-EOF |\
    sed -e "s/%dst/$arg1/g" \
        -e "s/%src/$arg2/g" \

  sra \$at, %src, 31 # \$at is either 0, or -1
  xor %dst, \$at, %src # %dst is either x or x-1
  subu %dst, %dst, \$at # either x + 0 or (x - 1) -1
EOF
}
