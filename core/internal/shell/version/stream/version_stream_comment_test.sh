#!/usr/bin/env zsh

eval $(./local test sm internal/version/stream )

: simple read/write

[[ -f "${sm_temp_path}/version_stream_1" ]]                                 # status!=0
echo 10 | __sm.version.stream.write.file "${sm_temp_path}/version_stream_1" # status=0

[[ -f "${sm_temp_path}/version_stream_1" ]]                                 # status=0
__sm.version.stream.read.file "${sm_temp_path}/version_stream_1"            # match=/^10$/

echo 1.1.1    | __sm.version.stream.increase.major # match=/^2.0.0$/
echo 1.0.0-rc | __sm.version.stream.increase.major # match=/^1.0.0$/
echo 1.1.1    | __sm.version.stream.increase.minor # match=/^1.2.0$/
echo 1.1.0-rc | __sm.version.stream.increase.minor # match=/^1.1.0$/
echo 1.1.1    | __sm.version.stream.increase.tiny  # match=/^1.1.2$/
echo 1.1.1-rc | __sm.version.stream.increase.tiny  # match=/^1.1.1$/
