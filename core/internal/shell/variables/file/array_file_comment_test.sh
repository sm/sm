#!/usr/bin/env zsh

eval $(./local test sm internal/variables/file )

: one line read
unset var1 var2
export -a var1 var2

printf "var1=(a b)" > "${sm_temp_path}/test-me"
__sm_variables_file_read_one "${sm_temp_path}/test-me" var1
# status=0; env[var2]=/^$/

echo ${var1[1]}
# match=/^a$/
echo ${var1[@]}
# match=/^a b$/

: multi line read
unset var1 var2
export -a var1 var2

printf "var1=(\nc\nd\n)" > "${sm_temp_path}/test-me"
__sm_variables_file_read_one "${sm_temp_path}/test-me" var1
# status=0; env[var2]=/^$/

echo ${var1[1]}
# match=/^c$/
echo ${var1[@]}
# match=/^c d$/

: multi line read ... not quoted
unset var1 var2
export -a var1 var2

printf "var1=(\ne f\ng h\n)" > "${sm_temp_path}/test-me"
__sm_variables_file_read_one "${sm_temp_path}/test-me" var1
# status=0; env[var2]=/^$/

echo ${var1[1]}
# match=/^e$/
echo ${var1[@]}
# match=/^e f g h$/

: one line write
unset var1 var2
export -a var1 var2

var1=(a b)
rm -f "${sm_temp_path}/test-me"
__sm_variables_file_write_one "${sm_temp_path}/test-me" var1 # status=0
[[ -f "${sm_temp_path}/test-me" ]]                           # status=0

cat "${sm_temp_path}/test-me"
# match=/^var1=\( a b \)$/

: one line update
unset var1 var2
export -a var1 var2

var1=(c d)
printf "var1=(a b)" > "${sm_temp_path}/test-me"
__sm_variables_file_write_one "${sm_temp_path}/test-me" var1 # status=0
[[ -f "${sm_temp_path}/test-me" ]]                           # status=0

cat "${sm_temp_path}/test-me"
# match=/^var1=\( c d \)$/
