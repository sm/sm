#!/usr/bin/env zsh

eval $(./local test sm internal/variables/file )

: one line read
unset var1 var2
export -a var1 var2

printf "var1=(a1 b2)" > "${sm_temp_path}/test-me"
# env[var1][]=0
__sm_variables_file_read_one "${sm_temp_path}/test-me" var1
# status=0
# env[var1][]=2
# env[var1][]=/^a1 b2$/
# env[var2][]=/^$/

: multi line read
unset var1 var2
export -a var1 var2

printf "var1=(\nc\nd\n)" > "${sm_temp_path}/test-me"
__sm_variables_file_read_one "${sm_temp_path}/test-me" var1
# status=0
# env[var1][]=2
# env[var1][]=/^c d$/
# env[var2][]=/^$/

: multi line read ... not quoted
unset var1 var2
export -a var1 var2

printf "var1=(\ne f\ng h\n)" > "${sm_temp_path}/test-me"
__sm_variables_file_read_one "${sm_temp_path}/test-me" var1
# status=0
# env[var1][]=4
# env[var1][]=/^e f g h$/
# env[var2][]=/^$/

: one line write
unset var1 var2
export -a var1 var2

var1=(a1 b2)
rm -f "${sm_temp_path}/test-me"
__sm_variables_file_write_one "${sm_temp_path}/test-me" var1 # status=0
[[ -f "${sm_temp_path}/test-me" ]]                           # status=0

cat "${sm_temp_path}/test-me"
# match=/^var1=\( a1 b2 \)$/

: one line update
unset var1 var2
export -a var1 var2

var1=(c d)
printf "var1=(a b)" > "${sm_temp_path}/test-me"
__sm_variables_file_write_one "${sm_temp_path}/test-me" var1 # status=0
[[ -f "${sm_temp_path}/test-me" ]]                           # status=0

cat "${sm_temp_path}/test-me"
# match=/^var1=\( c d \)$/
