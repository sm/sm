#!/usr/bin/env zsh

./local version &
pid=$!
[[ -d "${TMP_PATH:-/tmp}/sm-tmp-$pid" ]] # status=0
wait $pid
[[ -d "${TMP_PATH:-/tmp}/sm-tmp-$pid" ]] # status!=0
find "${TMP_PATH:-/tmp}/sm-tmp-*"        # status!=0

eval $(./local test sm)
pid=$$
[[ -d "${TMP_PATH:-/tmp}/sm-tmp-$pid" ]] # status=0
