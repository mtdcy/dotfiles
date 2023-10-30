#!/bin/bash

. $(dirname $(readlink -f $0))/xlib.sh 

function select_network_service {
    OLDPS3=$PS3
    PS3="Please select network service: "
    services=

    IFS=$'\n'
    services=($(networksetup -listallnetworkservices | sed '1d'))
    unset IFS

    select s in "${services[@]}" "Abort"; do
        [ "$s" = "Abort" ] && break

        PS3=$OLDPS3 
        echo "$s"
        break
    done
}

service="$(select_network_service)"
gfwGate=3

while true; do
    if ping -c1 10.10.10.2 > /dev/null 2>&1 ; then
        if [ $gfwGate -ne 1 ]; then
            xlog "switch to gfw gateway ..."
            # switch to gfw gate
            networksetup -setmanual "$service" 10.10.10.99 255.255.255.0 10.10.10.2
            networksetup -setdnsservers "$service" 10.10.10.2 10.10.10.1
            networksetup -setsearchdomains "$service" "local"
            gfwGate=1
        fi
    elif [ $gfwGate -ne 0 ]; then
        xlog "switch to main gateway ..."
        # switch to normal gate
        #networksetup -setdhcp "$service" 
        networksetup -setmanual "$service" 10.10.10.99 255.255.255.0 10.10.10.1
        networksetup -setdnsservers "$service" 10.10.10.1 10.10.10.2
        networksetup -setsearchdomains "$service" "local"
        gfwGate=0
    fi

    sleep 5
done
