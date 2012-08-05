#!/usr/bin/env zsh

eval $(./local test sm internal/version )

: basic comparision
__sm.version.compare 1 -gt 2 # status!=0
__sm.version.compare 2 -gt 2 # status!=0
__sm.version.compare 2 -gt 1 # status=0
__sm.version.compare 1 -ge 2 # status!=0
__sm.version.compare 2 -ge 2 # status=0
__sm.version.compare 2 -ge 1 # status=0
__sm.version.compare 2 -eq 1 # status!=0
__sm.version.compare 1 -eq 1 # status=0
__sm.version.compare 1 -eq 2 # status!=0
__sm.version.compare 1 -le 2 # status=0
__sm.version.compare 2 -le 2 # status=0
__sm.version.compare 2 -le 1 # status!=0
__sm.version.compare 1 -lt 2 # status=0
__sm.version.compare 2 -lt 2 # status!=0
__sm.version.compare 2 -lt 1 # status!=0

: two digit
__sm.version.compare 2     -gt 1.9  # status=0
__sm.version.compare 1.9   -gt 2    # status!=0
__sm.version.compare 2.0   -gt 1.9  # status=0
__sm.version.compare 2.0.0 -gt 1.9  # status=0

__sm.version.compare 1.10  -gt 1.9  # status=0
__sm.version.compare 1.9   -gt 1.10 # status!=0

: long ones
__sm.version.compare 1.1.2.1.1 -gt 1.1.1.1.2 # status=0
__sm.version.compare 1.1.1.1.2 -gt 1.1.2.1.1 # status!=0
__sm.version.compare 0.9.9.9.9 -gt 1.0.0.0.0 # status!=0
__sm.version.compare 1.0.0.0.0 -gt 0.9.9.9.9 # status=0
