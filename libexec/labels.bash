declare -a DATA_LABELS
declare -a TEXT_LABELS

function lookup_text_label() {
    eval echo \$text_label_${1}
}
function lookup_data_label() {
    eval echo \$data_label_${1}
}

function assign_data_label() {
   local _label="$1"
   local _value

   _value=$(lookup_data_label ${_label} )
   if [[ -z "${_value}" || "${_value}" == "undefined" ]] ; then   
      eval data_label_${_label}=$data_next
   else
      instruction_error "\"$_label\" has already been used as a label."
   fi 
}

function use_text_label() {
  local _label=$1
  local _value

  _value=$(lookup_text_label ${_label} )
  if [[ -z "${_value}" ]] ; then
    eval text_label_${_label}="undefined"
  fi
}

function assign_text_label() {
   local _label="$1"
   local _value

   _value=$(eval echo \$text_label_${_label})
   if [[ -z "${_value}" || "$_value" == "undefined" ]] ; then
     # This is the first time in which the label is being defined.
     eval text_label_${_label}=${REGISTER[$_pc]}
   else
     instruction_error "\"$_label\" has already been used as a label."
   fi 
}

function list_labels() {
  declare -p | grep ^data_label_ | while IFS='=' read name address ; do
      name=$(sed -e 's/data_label_//' -e 's/=/ /' <<< $name)
      printf "%s (0x%08x) : 0x%02x\n" $name $address ${MEM[$address]}
    done
             declare -p | grep ^text_label_ | while IFS='=' read name value ; do
      name=$(sed -e 's/text_label_//' -e 's/=/ /' <<< $name)
      printf "%s (0x%08x) : 0x%02x%d\n" $name $address ${MEM[$address]}
    done
}
