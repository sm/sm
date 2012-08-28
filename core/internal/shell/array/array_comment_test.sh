#!/usr/bin/env zsh

eval $( ./local test sm internal/array )

typeset -ga arr1
typeset var1
arr1=()

__sm.array.length arr1   # match=/^0$/
__sm.array.push   arr1 a # status=0
__sm.array.length arr1   # match=/^1$/
__sm.array.push   arr1 b # status=0
__sm.array.length arr1   # match=/^2$/
__sm.array.pop    arr1   # match=/^b$/; status=0
__sm.array.length arr1   # match=/^1$/
__sm.array.pop    arr1   # match=/^a$/; status=0
__sm.array.length arr1   # match=/^0$/
