#!/bin/sh 
#

# https://github.com/yonchu/shell-color-pallet/blob/master/color16
COLOR_RED="\\033[31m"
COLOR_GREEN="\\033[32m"
COLOR_YELLOW="\\033[33m"
COLOR_RESET="\\033[39m"

# xlog [error|info|warn] "message"
xlog() {
    local lvl=$(echo "$1" | tr 'A-Z' 'a-z')
    case "$lvl" in 
        error|info|warn)    shift 1     ;;
        *)                  lvl="text"  ;;
    esac

    local message=""
    case "$lvl" in
        "error")
            message="[$(date '+%Y-%m-%d %H:%M:%S')] $COLOR_RED$@$COLOR_RESET"
            ;;
        "info")
            message="[$(date '+%Y-%m-%d %H:%M:%S')] $COLOR_GREEN$@$COLOR_RESET"
            ;;
        "warn")
            message="[$(date '+%Y-%m-%d %H:%M:%S')] $COLOR_YELLOW$@$COLOR_RESET"
            ;;
        "text")
            message="[$(date '+%Y-%m-%d %H:%M:%S')] $@"
            ;;
    esac

    echo -e $message 
    [ "$lvl" = "error" ] && return 1 || return 0
}

# xar <create|extract|list> <path to compressed archive> [file list]
xar() {
    local cmd="tar"

    case "$1" in
        create)     cmd="$cmd -c"   ;;             
        extract)    cmd="$cmd -x"   ;;             
        list)       cmd="$cmd -t"   ;;
    esac
    shift 1

    cmd="$cmd -f $1"
    case "$1" in 
        *.tar.bz2)  cmd="$cmd -j"   ;;
        *.tar.gz)   cmd="$cmd -z"   ;;
        *.tar.xz)   cmd="$cmd -J"   ;;
    esac
    shift 1

    cmd="$cmd -v $@"
    xlog info "$cmd"
    eval $cmd
}

escape_path() {
    echo "$@" | sed 's/[.[\*^$]/\\&/g'
}
