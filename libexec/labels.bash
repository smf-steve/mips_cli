declare -a DATA_LABELS
declare -a TEXT_LABELS


function is_label () {
  local _name="$1"
  local _last_char=$(( ${#_name}-1))
  if [[ "${_name:${_last_char}}" == ":" ]] ; then
    echo TRUE
  else
    echo FALSE
  fi
}

function remove_label () {
   local first=$1 ; shift
   local rest="$@"

   if [[ $(is_label "$first" ) == "TRUE" ]] ; then
      echo "${rest}"
   else
      echo "${first} ${rest}"
  fi

}

function label_name () {
  local _name="$1"
  local _last_char=$(( ${#_name}-1 ))
  echo "${_name:0:$_last_char}"
}


# A label has one of three values:
#   ""           : previously not referenced nor defined
#   "undefined"  : previously referenced but not defined
#   address      : previously defined

function lookup_text_label() {
    eval echo "\$text_label_${1}"
}
function lookup_data_label() {
    eval echo "\$data_label_${1}"
}


function apply_data_labels () { 
   local labels="$1"
   local data_address="$2"
   local i

   for i in $labels ; do
      assign_data_label "$i" "${data_address}"
   done

}

function apply_text_labels () { 
   local labels="$1"
   local pc_address="$2"
   local i

   for i in $labels ; do
      assign_text_label "$i" "${pc_address}"
   done

}


function assign_data_label() {
   local _label="$1"
   local _address="$2"
   local _value
   if [[ -z "$_address" ]] ; then
      _address="${data_next}"
   fi

   _value=$(lookup_data_label "${_label}")
   case "$_value" in 
      "" )
            eval data_label_${_label}="${_address}"
            ;;
      "undefined" )
            eval data_label_${_label}="${_address}"
            ;;
       *)
            if (( _address != _value )) ; then 
               instruction_error "\"$_label\" being redefined."
            fi 
            ;;
   esac
}

function assign_text_label() {
   local _label="$1"
   local _address="$2"
   local _value

   _value=$(lookup_text_label "${_label}")
   case "$_value" in 
      "" )
            eval text_label_${_label}="${_address}"
            ;;
      "undefined" )
            eval text_label_${_label}="${_address}"
            ;;
       *)
            if (( _address != _value )) ; then 
               instruction_error "\"$_label\" being redefined."
            fi 
            ;;
   esac
}

function use_text_label() {
  local _label="$1"
  local _value

  _value=$(lookup_text_label ${_label} )
  if [[ -z "${_value}" ]] ; then
    eval text_label_${_label}="undefined"
  fi
}


function list_labels() {
  local name
  local address

  # Does not take into account the size of the instruction nor the data type
  declare -p | grep ^data_label_ | while IFS='=' read name address ; do
    name=$(sed -e 's/data_label_//' -e 's/=/ /' <<< $name)
    printf "%s (0x%08x) : 0x%02x\n" $name $address ${MEM[$address]}
  done
  declare -p | grep ^text_label_ | while IFS='=' read name address ; do
    name=$(sed -e 's/text_label_//' -e 's/=/ /' <<< $name)
    printf "%s (0x%08x) : 0x%08x %s\n" $name $address "${MEM[$address]}"  "\"${INSTRUCTION[$address]}\""
  done
}
