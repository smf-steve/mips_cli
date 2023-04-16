function  toDecimal() {
   # This function converts a number of various bases and notations
   # to a normal form.  This normal form a string represenaton of a 
   # decimal number.
   #
   # More this string also include either unary minus (-) or 
   # unary complement (~) operator as a prefix. 
   #
   # Valid input forms include
   #   1. a single ASCII character, e.g., a, \n, etc
   #      - note that the ASCII characters '0', '1', .. '9' are
   #        interpreted as a number
   #      - also note that such characters need not be quoted
   #   1. a decimal number, hexidecimal, octal, and binary number
   #      - note such numbers may have spaces in them for readability
   #        but must be quoted approprately to ensure proper shell processing
   #   1. a based number, e.g., 16#FACE.
   #      - note such number may have spaces in them for readability
   #      - also not such numbers may have a unary prefix after the base notaion.
   #
   #  Examaples:
   #
   #   ASCII input:  a, 'a', "a", '\n', \n, \20, 
   #   Non ASCII input:  1, '1', "1"    # such values are interpreted as a decimal number
   #
   #   Decimal numbers: -1234, ~1234, "- 1 123 456"
   #   Hex Octal, and Binary numbers '~ 0xFACE', "+ 0o 123 456", "- 0b0101 1001",  
   #   Tradintoal Octal numbers:  02344, -02345, "~ 023 345"
   #   
   #   Based numbers:   2#10100100, 16#-FACE, "16# ~ DE FACE"
   #
   #   Note the quoting above in necessary to preserve the input spacing.
   #     (A consequense of shell processing)


   #  Steps:
   #    1. strip out spacing and commas included for readability
   #    2. determine if a char, number, or base number
   #    3. if char
   #       1. exit
   #    4. if number
   #       1. determine the prefix
   #       convert the number to decimal
   #    5. apply the prefix

   _text="$(sed -e 's/ //g' -e 's/,//g' <<< $1)"

   _prefix=""
   _value="invalid immediate value"

   case $_text in
       *#* )
          _type=based
          ;; 
       [0-9+~-]* )  
          _type=number
          ;;
       * )
          _type=char
         ;;
   esac

   ##  Handle ASCII Characters
   if [[ ${_type} == "char" ]] ; then
       if [[ ${#_text} == 1 ]] ; then
         _value=$(LC_CTYPE=C printf '%d' "'$1")
       else
         _value="multi-char ASCII not implemented"
       fi
   fi

   ## Handle Numbers
   if [[ ${_type} == "number" ]] ; then 
      _first=${_text:0:1}
      if [[ ${_first} == "+" ]] ; then 
        _text=${_text:1}     # remove superflous +
      fi

      if [[ ${_first} == '~' || ${_first} == '-' ]] ; then 
        _prefix=${_first}
        _text=${_text:1}
      fi

      # Check to see if it's a "0b"
      if [[ "${_text:0:2}" == "0b" || "${_text:0:2}" == "0B" ]] ; then 
         _type=based
         _text="2#${_text:2}"
      fi
      # Check to see if it's the newform octal
      if [[ "${_text:0:2}" == "0o"  || "${_text:0:2}" == "0O" ]] ; then 
         _text="0${_text:2}"
      fi

      if [[ ${_type} == "number" ]] ; then
         _value=$(( _text ))
      fi
   fi


    ## Handle based numbers 
    if [[ "${_type}" == "based" ]] ; then 
       _base=${_text%#*}
       _digits=${_text#*#}
       _first=${_digits:0:1}

       if [[ ${_first} == "+" ]] ; then 
        _digits=${_digits:1}     # remove superflous +
      fi

      if [[ ${_first} == '~' || ${_first} == '-' ]] ; then 
        _prefix=${_first}
        _digits=${_digits:1}
      fi
      _text=${_base}#${_digits}
      _value=$(( _text ))
    fi 
 
    echo ${_prefix}${_value}
}
