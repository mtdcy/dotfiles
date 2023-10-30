#!/bin/bash
#

XPWD="$(pwd)"
XTWD=$(readlink -f "$0" | xargs dirname)

function usage {
    cat << EOF
$(basename $0) <action [options]>
    try 
        connect <host[:port]> [via <iface|host>]    - 

EOF
}

# xlog newline "text line"
function xlog {
    [ "$1" = "newline" ] && echo "" && shift 

    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$@"
}

# xconnect xdst xvia
function xconnect {
    xlog "xconnect $1 $2"

    _dst_host=$(echo $1 | awk -F: '{ print $1 }')
    _dst_port=$(echo $1 | awk -F: '{ print $2 }')

    _via_intf=$(echo $2 | awk -F: '{ print $1 }')
    _via_port=$(echo $2 | awk -F: '{ print $2 }')

    xlog newline "perform ping test ..."
    _cmd="ping $_dst_host -t 3"

    xlog "$_cmd"
    eval -- $_cmd

    which traceroute > /dev/null 
    if [ $? -eq 0 ]; then
        xlog newline "perform udp trace ..."
        _cmd="traceroute -w 1"
        [ ! -z "$_dst_port" ] && _cmd+=" -p $_dst_port"
        [ ! -z "$_via_intf" ] && _cmd+=" -i $_via_intf"

        _cmd+=" $_dst_host"

        xlog "$_cmd"
        eval -- $_cmd
    else
        xlog newline "skip udp trace ..."
    fi

    which tcptraceroute > /dev/null 
    if [ $? -eq 0 ]; then 
        xlog newline "perform tcp trace ..."
        _cmd="sudo tcptraceroute"
        [ ! -z "$_via_intf" ] && _cmd+=" -i $_via_intf"

        _cmd+=" $_dst_host $_dst_port"

        xlog "$_cmd"
        eval -- $_cmd
    else
        xlog newline "skip tcp trace ..."
    fi

    #xlog newline "perform dns lookup ..."
    #_cmd="dig $_dst_host"
    #[ ! -z $_via_intf ] && _cmd+=" @$_via_intf"
    #[ ! -z $_via_port ] && _cmd+=" -p $_via_port"

    #xlog "$_cmd"
    #eval -- $_cmd
}

xdst=
xvia=

while [ $# -gt 0 ]; do
    _act=$1; shift

    case "$_act" in 
        "connect")
            xdst=$1; shift;;
        "via")
            xvia=$1; shift;;
        *)
            usage;;
    esac
done

xconnect $xdst $xvia
