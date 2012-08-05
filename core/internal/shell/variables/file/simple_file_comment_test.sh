#!/usr/bin/env zsh

eval $(./local test sm internal/variables/file )

export _sm_version_read1 _sm_version_read2
__sm_variables_file_read _sm_version_read1 VERSION
# status=0
# env[_sm_version_read1]=/[[:digit:]\.]+/

echo $_sm_version_read1
# match=/[[:digit:]\.]+/

## write / read test
_sm_version_read1=100
[[ -f "${sm_temp_path}/VERSION" ]]
# status!=0
__sm_variables_file_write _sm_version_read1 "${sm_temp_path}/VERSION"
# status=0
[[ -f "${sm_temp_path}/VERSION" ]]
# status=0
__sm_variables_file_read _sm_version_read2 "${sm_temp_path}/VERSION"
# status=0
# env[_sm_version_read2]=/^100$/
