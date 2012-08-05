#!/usr/bin/env zsh

eval $(./local test sm internal/variables )


: variable is array
typeset val_string
__sm.variable.is.array "val_string" # status!=0
typeset -a val_array
__sm.variable.is.array "val_array"  # status=0
