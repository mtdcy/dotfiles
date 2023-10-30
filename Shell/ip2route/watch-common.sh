#!/bin/bash 

IFS='@' read _ gw netif <<< $0
netif=${netif%.sh}

cd $(dirname $0) 
echo "$PWD: ip2route @ $gw @ $netif ..."

symlink=/etc/dnsmasq.d/servers

# force reset 
sleep 1
unlink $symlink
systemctl restart dnsmasq 

on_netif_ready() {
    [ -L $symlink ] && return 0

    echo "ip2route: $gw @ $netif is ready" 

    find $PWD -name "*-*@$gw@$netif*" -exec bash {} > /dev/null \;
    ln -svf $PWD/dnsmasq.auto $symlink 
    systemctl restart dnsmasq 
}

on_netif_down() {
    [ -L $symlink ] || return 0

    echo "ip2route: $gw @ $netif is down"
    unlink $symlink 
    systemctl restart dnsmasq 
}

while true; do
    ip addr show $netif 2>&1 > /dev/null 
    if [ $? -ne 0 ]; then
        on_netif_down 
        exit 0
    fi

    ping -c1 $gw 2>&1 > /dev/null 
    if [ $? -ne 0 ]; then
        on_netif_down 

        echo "ip2route: $gw @ $netif unreachable, wait ..."
        sleep 15 
        continue
    fi

    on_netif_ready 
    sleep 30
done 
