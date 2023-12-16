#!/bin/bash 
# Connect remote host and handle copy to local pasteboard 

set -e 

cd $(dirname $0) 
. xlib.sh 

PORT=10000

pbcopy="pbcopy" 
netstat="netstat -anp tcp"   # macOS
if [ "$(uname)" = "Linux" ]; then
    pbcopy="xclip -selection clipboard"
    netstat="netstat -tnlp"
fi

# find available port
while true; do
    $netstat | grep $PORT 2>&1 > /dev/null || break
    PORT=$(expr $PORT + 1)
done

xlog info "$$: start copy/paste listen @ $PORT"
{ 
    # start a subshell 
    xlog info "$$: start listening ..."
    while true; do
        text=$(nc -l $PORT)
        [ "$text" == "$$" ] && break # stop when received pid

        echo "$text" | $pbcopy 
    done
    xlog info "$$: stop listening ..."
} &

# for zsh, save this to rcopy.sh to remote
rcopy() {
    if [ ! -r "$@" ]; then
        echo "$@ does not exists, or access denied ..."
        return 1
    fi
    read client _ <<< "$SSH_CLIENT"
    cat "$@" | nc localhost $SSH_RCOPY_PORT
    echo "copied $@ to $client:$SSH_RCOPY_PORT pasteboard"
}

# export -f is not portable => impossible in zsh 
ssh -t -R $PORT:localhost:$PORT $@ "export SSH_RCOPY_PORT=$PORT; $(declare -f rcopy); export -f rcopy 2> /dev/null; exec \$SHELL -li"

xlog info "$$: exit ..."
echo "$$" | nc localhost $PORT
