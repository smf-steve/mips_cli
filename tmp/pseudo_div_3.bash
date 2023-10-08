alias div="prefetch_macro div"

function pseudo_div_3  () {
    
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

  bne %src, \$zero, 4 ## look no label
  break
  div %src1, %src2
  mflo %dst
EOF
}
