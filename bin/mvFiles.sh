#!/bin/bash 
#
# rename.sh <origin name string> <new name string> 
#

if [ $# -lt 2 ]; then
    cat << EOS
usage: $(basename $0) <origin name string> <new name string> [destination]
EOS
    exit 1
fi

dest=.
[ $# -gt 2 ] && dest=$3
[ -d "$dest" ] || mkdir -pv "$dest"

# escape regx patten characters
pat="$(echo "$1" | sed 's/[.[\*^$]/\\&/g')"

find . -name "${pat}*" -type f | while read file; do 
    alt=$(echo "$file" | sed "s/$pat/$2/")
    echo "$file => $dest/$alt"
    mv "$file" "$dest/$alt"
done
