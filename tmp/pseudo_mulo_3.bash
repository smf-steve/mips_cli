alias mulo="prefetch_macro mulo"

function pseudo_mulo_3  () {
    
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

  mult %src1, %src2
  mfhi \$at
  mflo %dst
  sra %dst, %dst, 31
  beq \$at, %dst, 4
  break
  mflo %dst
EOF
}
