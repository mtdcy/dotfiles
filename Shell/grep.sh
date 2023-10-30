#!/bin/bash

GREP=`which grep`

OPTIONS="-R --exclude-dir=.repo --exclude-dir=.svn --exclude-dir=.git --exclude=*~ --binary-files=without-match --color=auto -H -n --line-buffered"

$GREP $OPTIONS "$@"
