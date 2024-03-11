#!/bin/sh

echo ""

#$HOME/.bin/screenfetch -E

neofetch=$(which neofetch 2> /dev/null)
[ -x $HOME/.bin/neofetch ] && neofetch=$HOME/.bin/neofetch
[ -x /usr/local/bin/neofetch ] && neofetch=/usr/local/bin/neofetch
[ -x /home/linuxbrew/.linuxbrew/bin/neofetch ] && neofetch=/home/linuxbrew/.linuxbrew/bin/neofetch

sed -e 's/cpu_temp=.*$/cpu_temp="C"/' \
    -e 's/memory_unit=.*$/memory_unit=gib/' \
    -e 's/speed_shorthand=.*$/speed_shorthand=on/' \
    -i $HOME/.config/neofetch/config.conf &> /dev/null || true
$neofetch
