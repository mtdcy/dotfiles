#!/bin/bash

# $0 <old> <new> <path> 

OPTS=("")
PARS=()

for arg in "$@"; do
    case $arg in
        -w)     OPTS+=("-w");;
        *)      PARS+=("$arg");;
    esac
done

OLD=${PARS[0]}
NEW=${PARS[1]}
TGT=${PARS[@]:2}

CMD="grep.sh -l $OPTS '${OLD[@]}' ${TGT[@]} | xargs sed -i "
if [[ ${OPTS[@]} =~ "-w" ]]; then
    CMD+=" 's%\<${OLD[@]}\>%${NEW[@]}%g'"
else
    CMD+=" 's%${OLD[@]}%${NEW[@]}%g'"
fi

echo $CMD
eval -- $CMD
