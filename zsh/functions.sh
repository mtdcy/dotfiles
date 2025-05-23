#!/bin/bash

# screen
function screen_attach_or_open() {
    [ $# -gt 0 ] && screen "$@" && return
    screen -D -R -S "$(basename $PWD)"
}

function tmux_attach_or_new() {
    # run tmux commands
    [ $# -gt 0 ] && tmux "$@" && return
    # detach if inside tmux
    [ -n "$TMUX" ] && tmux detach && return
    # attach or new
    local ses=($(tmux list-sessions | awk -F: '{print $1}' | xargs))
    if [ $#ses -gt 0 ]; then
        echo -en "Current sessions:\n"
        for ((i=1; i < ($#ses + 1); i++)) echo " $i) ${ses[$i]}"
        echo -en "\nPlease select session (Enter to start new session): "
        read ans
        if [ -z "$ans" ] || [ "$ans" -gt $#ses ]; then
            tmux new -t "$(basename "$PWD")"
        else
            tmux attach -t "${ses[$ans]}"
        fi
    else
        tmux new -t "$(basename "$PWD")"
    fi
}

function extract () {
    if [ -f "$1" ]; then
	    case "$1" in
		    *.tar.bz2)  tar xvjf "$@" 	;;
    		*.tar.gz) 	tar xvzf "$@" 	;;
            *.tar.xz)   tar xvfJ "$@"   ;;
	    	*.bz2) 		bunzip2  "$@" 	;;
    		*.rar) 		unrar x  "$@" 	;;
	    	*.gz) 		gunzip   "$@" 	;;
		    *.tar) 		tar xvf  "$@" 	;;
    		*.tbz2) 	tar xvjf "$@" 	;;
	    	*.tgz) 		tar xvzf "$@" 	;;
		    *.zip) 		unzip    "$@" 	;;
	    	*.7z) 		7z x     "$@" 	;;
		    *) 	echo "Error: don't knwon how to extract $* ..." ;;
	    esac
    else
	    echo "'$1' doesn't exist ..."
    fi
}

function grep.sh() {
    local opts=(
        -H -n -R 
        --color=auto 
        --exclude-dir=.git 
        --exclude-dir=__pycache__ 
        --binary-files=without-match 
        --devices=skip
    )
    grep "${opts[@]}" "$@"
}

function replace.sh() { # <match> <replacement> <target>
    grep.sh -w -l "$1" "$3" | xargs sed -i "s/\<$1\>/$2/g"
}

# sudo & systemd
#alias sudo="sudo env \"PATH=$PATH\""
alias sudo="sudo --preserve-env=PATH"
export SYSTEMD_EDITOR=vim

# alias: gnu utils preferred
hidden="--hide='@*' --hide='#recycle'"
if which gls &> /dev/null; then
    alias ls="gls --color=auto $hidden"
elif ls --version 2>/dev/null | grep -F "GNU coreutils" &> /dev/null; then
    alias ls="ls --color=auto $hidden"
else
    alias ls='ls -G' # macOS ls, no hide
fi
alias ll='ls -lh'
alias lla='ls -lha'
unset hidden

alias du="du -ah --time --max-depth=1 --exclude='@eaDir' 2>/dev/null"

alias grep='grep --color=auto'

alias nvimdiff='nvim -d'

alias ping="ping -c3"

alias history="history 0"

# Big alias
alias G='lazygit'

if which tmux &> /dev/null; then
    alias T='tmux_attach_or_new'
else
    alias T='screen_attach_or_open'
fi
