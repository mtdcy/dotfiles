[ -z "$PS1" ] && return

# shell completion #{{{
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi
# fast shellcompletion
#set show-all-if-ambiguous on
#}}}

# default font dir, currently only used by gnuplot
#export GDFONTPATH=/home/peter/.fonts

# for OOO

# Prompt #{{{
unset PS1 PS2 PS3 PS4
# colorful PS1
if [ $(id -u) -eq 0 -o "$USER" = "root" ]; then
  # root user
  export PS1='[\e[31m\u@\h \e[34m\w\e[m] \e[31m\#\e[m '
elif echo $TERM | grep "xterm-*\|*-256color" > /dev/null; then
  # https://www.ditig.com/256-colors-cheat-sheet
  export PS1='[\e[38;5;76m\u@\h \e[38;5;63m\w\e[m] \e[38;5;40m\$\e[m '
else
  # non root
  export PS1='[\e[32m\u@\h \e[34m\w\e[m] \e[32m\$\e[m '
fi
PS2='+> '
PS3='+++> '
PS4='+++++> '
#PROMPT_COMMAND='RET=$?; if [[ $RET=0 ]]; then echo -ne "\033[4;32m$RET\033[0m"; else echo -ne "\033[4;31m$RET\033[0m"; fi; echo -n " "'
#case ${TERM} in
#	xterm*|rxvt*|Eterm|aterm|kterm|gnome*|interix)
#		PROMPT_COMMAND='RET=$?; if [[ $RET = 0 ]]; then echo -ne "\033[30;42m$RET\033[0m"; else echo -ne "\033[30;41m$RET\033[0m"; fi;echo -ne "\033]0;${PWD/$HOME/~}\007"'
#		;;
#	screen)
#		PROMPT_COMMAND='RET=$?; if [[ $RET = 0 ]]; then echo -ne "\033[30;42m$RET\033[0m"; else echo -ne "\033[30;41m$RET\033[0m"; fi;echo -ne "\033_${PWD/$HOME/~}\033\\"'
#		;;
#esac
#}}}

# some alias

# General# {{{
#eval "`dircolors -b`"
alias ls='ls --color=auto'
ls --version | grep coreutils > /dev/null 2>&1
if [ $? -eq 0 ]; then
    alias ls='ls --color=auto'  # GNU coreutils
else
    alias ls='ls -G'
fi

alias ll='ls -lh'
alias la='ls -A'
alias lla='ls -la'
alias du='du -h --max-depth=1'

#alias rm='rm -i'
alias ping="ping -c3"

# sudo preserve PATH
alias sudo="sudo env \"PATH=$PATH\""

which trash > /dev/null 2>&1 && alias rm="trash"
# }}}

# extract#{{{
extract () {
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
#}}}

# colorize the man-pages#{{{
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'
#}}}


# MISC #{{{
#export GREP_OPTIONS='-R --exclude-dir=.svn --exclude-dir=.git --exclude=*~ --binary-files=without-match --color=auto -H -n'

#export HISTSIZE=5000
#export HISTTIMEFORMAT='%F %T '
export HISTCONTROL=erasedups:ignorespace:ignoredups

export EDITOR=vim
export SYSTEMD_EDITOR=vim

# for mac, make ls output colors
export CLICOLOR=1
export LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lz=01;31:*.xz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.axa=00;36:*.oga=00;36:*.spx=00;36:*.xspf=00;36:';

# set the number of open files to be 1024
ulimit -S -n 1024

[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

##}}}

# homebrew & linuxbrew
[ -d /home/linuxbrew ]     && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
[ -x /usr/local/bin/brew ] && eval "$(/usr/local/bin/brew shellenv)"

if which brew &> /dev/null; then
    brewprefix="$(brew --prefix)" # run only once to reduce start time
    export PATH="$brewprefix/opt/coreutils/libexec/gnubin:$PATH"
    export PATH="$brewprefix/opt/gnu-sed/libexec/gnubin:$PATH"
    export PATH="$brewprefix/opt/grep/libexec/gnubin:$PATH"

    export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.mtdcy.top/homebrew-bottles
    export HOMEBREW_API_DOMAIN=https://mirrors.mtdcy.top/homebrew-bottles/api
fi

export PATH=$HOME/.bin:$PATH
. "$HOME/.cargo/env"
. "/home/mtdcy/.deno/env"