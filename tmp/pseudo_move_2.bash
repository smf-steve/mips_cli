alias move="prefetch_macro move"

function pseudo_move_2  () {
    
  # remove optional commas
  # quote arg that contains a space
  local arg1="$(sed -e 's/,$//' -e 's/\(.* .*\)/1/' <<< $1)"
  local arg2="$(sed -e 's/,$//' -e 's/\(.* .*\)/1/' <<< $2)"

  # apply the subsitution from longest to shortest
  # for now, just first to last
  cat <<-EOF |\
    sed -e "s/%rdst/$arg1/g" \
        -e "s/%rsrc/$arg2/g" \

  sll %rdst, %rsrc, 0
EOF
}
