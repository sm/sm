#!/usr/bin/env zsh

source test-sm

log "one"         # match=/^one$/; status=0

log warn "two"    # match=/^WARNING: two$/; status=0

## this one is overwritten, by default it would exit shell - which would break the test
log error "three" # match=/^ERROR\(log\): three$/; status=122
