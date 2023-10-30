#!/bin/bash 

xwd=$(dirname $(readlink -f "$0"))
. "$xwd/xlib.sh"

shc="$xwd/$(uname -s | tr A-Z a-z)/$(uname -m)/$(basename $0)"

xlog "$shc $*"
exec "$shc" "$@"
