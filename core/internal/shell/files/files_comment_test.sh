#!/usr/bin/env zsh

source   test-sm
includes internal/files

touch "${sm_temp_path}/a"
ln -s "${sm_temp_path}/a" "${sm_temp_path}/b"
ln -s "${sm_temp_path}/b" "${sm_temp_path}/c"

__sm.files.readlinks "${sm_temp_path}/c" # match=/\/a$/
