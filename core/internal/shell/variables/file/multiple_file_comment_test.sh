#!/usr/bin/env zsh

eval $(./local test sm internal/variables/file )

: read one
unset var1 var2
export var1 var2

printf "var1=a\nvar2=b\n" > "${sm_temp_path}/test-me"
__sm_variables_file_read_one "${sm_temp_path}/test-me" var1
# status=0; env[var1]=/^a$/; env[var2]=/^$/

: read all
unset var1 var2 var3 var4
export var1 var2 var3 var4

printf "var1=a\nvar2=b\nvar3=c\n" > "${sm_temp_path}/test-me"
__sm_variables_file_read_all "${sm_temp_path}/test-me"
# status=0; env[var1]=/^a$/; env[var2]=/^b$/; env[var3]=/^c$/; env[var4]=/^$/

: read many
unset var1 var2 var3 var4
export var1 var2 var3 var4

printf "var1=a\nvar2=b\nvar3=c\n" > "${sm_temp_path}/test-me"
__sm_variables_file_read_many "${sm_temp_path}/test-me" var1 var3
# status=0; env[var1]=/^a$/; env[var2]=/^$/; env[var3]=/^c$/; env[var4]=/^$/

: write one
var1=aa
var2=bb

printf "var1=a\nvar2=b\n" > "${sm_temp_path}/test-me"
__sm_variables_file_write_one "${sm_temp_path}/test-me" var1
__sm_variables_file_read_all "${sm_temp_path}/test-me"
# status=0; env[var1]=/^aa$/; env[var2]=/^b$/;

: write many
var1=aa
var2=bb
var3=cc

printf "var1=a\nvar2=b\nvar3=c\n" > "${sm_temp_path}/test-me"
__sm_variables_file_write_many "${sm_temp_path}/test-me" var1 var3
__sm_variables_file_read_all "${sm_temp_path}/test-me"
# status=0; env[var1]=/^aa$/; env[var2]=/^b$/; env[var3]=/^cc$/; env[var4]=/^$/
