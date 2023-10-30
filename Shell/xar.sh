#!/bin/bash

. $(dirname $0)/xlib.sh 

case "$1" in 
    create|list|extract)
        xar $1 "$2" "${@:3}"
        ;;
    *)
        xar list "$@"
        ;;
esac
