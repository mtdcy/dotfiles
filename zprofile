#!/bin/sh

echo ""

#$HOME/.bin/screenfetch -E

neofetch=$(which neofetch 2> /dev/null)
[ -x $HOME/.bin/neofetch ] && neofetch=$HOME/.bin/neofetch
[ -x /usr/local/bin/neofetch ] && neofetch=/usr/local/bin/neofetch
[ -x /home/linuxbrew/.linuxbrew/bin/neofetch ] && neofetch=/home/linuxbrew/.linuxbrew/bin/neofetch

$neofetch
