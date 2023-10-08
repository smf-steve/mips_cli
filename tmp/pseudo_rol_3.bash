alias rol="prefetch_macro rol"

function pseudo_rol_3  () {
    
  # remove optional commas
  # quote arg that contains a space
  local arg1="$(sed -e 's/,$//' -e 's/\(.* .*\)/1/' <<< $1)"
  local arg2="$(sed -e 's/,$//' -e 's/\(.* .*\)/1/' <<< $2)"
  local arg3="$(sed -e 's/,$//' -e 's/\(.* .*\)/1/' <<< $3)"

  # apply the subsitution from longest to shortest
  # for now, just first to last
  cat <<-EOF |\
    sed -e "s/%dst/$arg1/g" \
        -e "s/%src/$arg2/g" \
        -e "s/%imm/$arg3/g" \

  srl \$at, %src, \$(( 32 - %imm))
  sll %dst, %src, %imm
  or %dst, %dst, \$at
EOF
}
