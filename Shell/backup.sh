#!/bin/sh 
# 
# usage 

. $(dirname $0)/xlib.sh 

usage() {
    cat << EOS
$(basename $0) <action> <parameters> <options> 
   
Actions:
    backup <backup profile>     - backup given files specified by profile 
    restore <archive file>      - restore files from archive file 

Options:

EOS
}

backup() {
    [ -e "$1" ] || { xlog error "$1 not exists"; return 1; }

    local list=

    while read line; do
        [ -e "$line" ] || { xlog warn "$line not exists"; continue; }

        list="$list $line"

        # backup the real file too
        [ -L "$line" ] && list="$list $(readlink -f $line)"
    done < $1

    target="${1%.*}_$(date '+%Y%m%d_%H%M%S').tar.gz" 
    xlog info "backup to $target"

    xar create "$target" $list
}

restore() {
    cd /
    xar extract "$1"
}

[ $# -ge 1 ] || { usage; exit 1; }

case "$1" in 
    help)   
        usage
        exit 0
        ;;
    restore) 
        restore "$2"
        ;;
    backup)
        backup "$2" 
        ;;
    *)
        # default action
        backup "$1"
        ;;
esac
