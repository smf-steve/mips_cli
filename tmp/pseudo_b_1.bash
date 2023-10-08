alias b="prefetch_macro b"

function pseudo_b_1  () {
    
  # remove optional commas
  # quote arg that contains a space
  local arg1="$(sed -e 's/,$//' -e 's/\(.* .*\)/1/' <<< $1)"

  # apply the subsitution from longest to shortest
  # for now, just first to last
  cat <<-EOF |\
    sed -e "s/%label/$arg1/g" \

  beq \$zero, \$zero, %label
EOF
}
