#!/usr/bin/env zsh

source test-sm

log "one"         # match=/^one$/; status=0

log warn "two"    # match=/^WARNING: two$/; status=0

