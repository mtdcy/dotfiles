#!/bin/bash
#

#set -e 
set -x

[ "$(id -u)" -ne 0 ] && echo "please run as root" && exit 1

source "$(dirname $0)/xlib.sh"

function usage {
    cat << EOF
socks5.sh <action [argument]> ...
    connect [user@]server[:port]    - connect remote server 
    bind <ip:port>                  - bind local address
    ident <user>                    - specify identify file by user name
    run                             - run ssh, otherwise print the command and parameters
    verbose                         - run ssh in verbose mode
    help                            - show this help message.

Examples:
    socks5.sh connect user@example.com bind '*:1080' run verbose > /dev/null 2>&1 &
EOF
}

logfile=/tmp/socks5-$$.log
pidfile=/tmp/socks5.pid 
sshc="ssh -fCN "
run=0
serv=
bind="*:1070" # def local binding port

# optimized ssh parameters
sshc+="-o ConnectTimeout=60 "      # default tcp timeout is 60s
sshc+="-o ConnectionAttempts=99 "

while [ $# -gt 0 ]; do
    opt=$1; shift

    case $opt in 
        "connect") 
            user=${1%@*}
            serv=${1#*@}
            shift

            # fix user
            [ "$user" = "$serv" ] && user=""

            host=$(echo $serv | cut -d : -f 1)
            port=$(echo $serv | cut -d : -f 2)

            [ -z "$host" ] && xlog "bad host $host, exit." && exit 1

            [ -z "$user" ] || sshc+="$user@"
            sshc+="$host "
            [ -z "$port" ] || sshc+="-p $port "
            ;;
        "bind")
            bind=$1; shift
            lport=$(echo $bind | cut -d : -f 2)

            [ -z "$lport" ] && xlog "bad bind address $bind, exit." && exit 2

            sshc+="-D $bind "
            ;;
        "ident")
            user=$1; shift
            sshc+="-i /home/$user/.ssh/id_rsa "
            ;;
        "verbose")
            sshc+="-v "
            ;;
        "run")
            run=1
            ;;
        "help"|*)  
            usage
            exit 255
            ;;
    esac
done

# sanity checks
[ -z "$serv" ] && xlog "no server been specified, exit." && exit 1

# starting socks5 tunnel 
xlog "socks5 @ ${sshc}"

# redirect log
exec 2>&1
exec 1>$logfile

echo $sshc | grep "\-D" > /dev/null 2>&1 
[ $? -ne 0 ] && xlog "bind @ $bind by default" && sshc+="-D $bind "

xlog "connect server $serv and listen @ $bind ..."

[ $run -eq 0 ] && exit 0

# monitor pid, not socks5 daemon pid
# kill old monitor 
[ -z "$(cat $pidfile)" ] || kill $(< $pidfile) 
echo $$ > $pidfile 

function socks5_pid {
    netstat -tnlp | grep -w -E "$bind .*[0-9]+/ssh" | awk '{ print $7 }' | cut -d / -f 1 | uniq
}

pid=$(socks5_pid)
if [ ! -z "$pid" ]; then
    xlog info "kill old socks5 daemon: $pid"
    kill $pid
fi

int=15 
while true; do
    [ ! -z "$(socks5_pid)" ] && {
        xlog "socks5 deamon is ready, sleep ..."
        sleep $int 
        [ $int -lt 300 ] && int=$((int + 15))
        continue
    }

    xlog "@@ connecting/reconnecting server ... @@"
    xlog "sshc: $sshc"

    # here will start a new pipe process
    #$sshc 2>&1 | while read line; do xlog "$line"; done 
    $sshc exit 2>&1 

    int=15
    sleep $int
done

exit 0
