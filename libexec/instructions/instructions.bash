#! /bin/bash

source libexec/instructions/directives.bash
source libexec/instructions/native_instructions.bash
source libexec/instructions/pseudo_instructions.bash
source libexec/instructions/synonym_instructions.bash


function instruction_type () {
  local name="$1"
  # returns either native, pseudo, synonym, macro or FALSE
  # depending on 
}

function is_macro () {
  local name="$1"
  # determines if the name is a created user macro
  # need to create an Array that records each macro
  # name, argc, function   ;  name x argc --> function

  # returns FALSE or function
}