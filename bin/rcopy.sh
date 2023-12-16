#!/bin/bash
# A script work with remote.sh 
# Copy remote file text to local pasteboard

rcopy()  {
    if [ ! -r "$@" ]; then
        echo "$@ does not exists, or access denied ..."
        return 1
    fi
    read client _ <<< "$SSH_CLIENT"
    cat "$@" | nc localhost $SSH_RCOPY_PORT
    echo "copied $@ to $client:$SSH_RCOPY_PORT pasteboard"
}
rcopy $@
