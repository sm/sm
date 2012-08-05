#!/usr/bin/env zsh

eval $(./local test sm internal/files )

: readlinks
touch "${sm_temp_path}/a"
ln -s "${sm_temp_path}/a" "${sm_temp_path}/b"
ln -s "${sm_temp_path}/b" "${sm_temp_path}/c"

## reading /c should resolve to /a
__sm.files.readlinks "${sm_temp_path}/c" # match=/\/a$/
