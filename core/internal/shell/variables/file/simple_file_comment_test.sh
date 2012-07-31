#!/usr/bin/env zsh

source   test-sm
includes internal/variables/file

export _sm_version_read
__sm_variables_file_read _sm_version_read VERSION
# status=0
# env[_sm_version_read]=/[[:digit:]\.]+/

echo $_sm_version_read
# match=/[[:digit:]\.]+/
