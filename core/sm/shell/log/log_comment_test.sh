#!/usr/bin/env zsh

eval $(./local test sm)

log "one"          # match=/^one$/;                 status=0
log warn "two"     # match=/^WARNING: two$/;        status=0
log succeed "yes?" # match=/yes?/;                  status=0
log fail    "no!"  # match=/FAIL\(log\): no!/;      status=121 ## this one is overwritten, by default it would exit shell - which would break the test
# match=/===/ ## part of stacktrace header
log error "three"  # match=/^ERROR\(log\): three$/; status=122 ## this one is overwritten, by default it would exit shell - which would break the test

log step "1" true  # match=/] 1/;                   status=0
log step "2" false # match=/] 2!/;                  status!=0
log step "3"       # match=/] 3.../;                status=0
log step succ      # match=/] 3/;                   status=0
log step "4"       # match=/] 4.../;                status=0
log step failure   # match=/] 4!/;                  status=0

__sm.log.options.check "one two" "one"   # status=0
__sm.log.options.check "one two" "two"   # status=0
__sm.log.options.check "one two" "three" # status!=0

debug_flag=0 debug_flags="test1" log debug test1 "out1" # match=/^$/
debug_flag=1 debug_flags="test1" log debug test1 "out2" # match=/^DEBUG test1: out2$/
debug_flag=1 debug_flags="all"   log debug test1 "out3" # match=/^DEBUG test1: out3$/
debug_flag=1 debug_flags="test1" log debug test2 "out4" # match=/^$/

echo "pipe1" | debug_flag=1 debug_flags="test1" log debug test1 - # match=/^DEBUG test1 -->/; match=/^pipe1$/; match=/^DEBUG test1 <--/
echo "pipe2" | debug_flag=1 debug_flags="test1" log debug test2 - # match=/^$/

debug_flag=0 debug_flags=""       log search "1" "2" "3" # match=/^$/
debug_flag=1 debug_flags="search" log search "1" "2" "3" # match=/^DEBUG search:         1 2                         in 3.$/

debug_flag=0 debug_flags=""     log todo "nothing" # match=/^$/
debug_flag=1 debug_flags="todo" log todo "nothing" # match=/^DEBUG todo: . nothing$/

printf "\n\n\n\n" | log dotted # match=/^\.\.\.\.$/

##log rotate "20"
##log streams "null"
