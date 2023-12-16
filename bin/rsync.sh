#!/bin/bash

function usage {
    cat << EOF
rsync.sh <action> ...
    pull            - pull from remote 
    push            - push to remote
EOF
}

ldir=$(dirname $(readlink -f $0))/
rdir=mtdcy@iSynoNAS.local:/volume3/repositories/xlab.git/

while [ $# -gt 0 ]; do
    act=$1; shift;

    case "$act" in 
        "pull")
            rsync -rP --exclude=.git $rdir $ldir
            ;;
        "push")
            rsync -rP --exclude=.git $ldir $rdir
            ;;
        *)
            usage 
            exit 1
            ;;
    esac
done
