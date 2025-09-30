#!/bin/bash

# umask not always work with syno
umask 0022

# Fix timezone: missing TZ env
export TZ=$(cat /etc/TZ)

# fix term colors
export TERM=xterm

source $HOME/.zprofile

#exec /usr/local/bin/zsh
ZSH=$(which zsh)
if test -x $ZSH; then
    export SHELL=$ZSH
    exec $ZSH
fi
