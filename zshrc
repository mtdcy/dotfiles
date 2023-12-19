
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# reconfig with 'autoload -U zsh-newuser-install && zsh-newuser-install'
# Lines configured by zsh-newuser-install
HISTFILE=$HOME/.zsh/history
HISTSIZE=10000
SAVEHIST=10000
setopt autocd beep extendedglob histfindnodups histignorealldups
setopt nomatch notify
bindkey -v
# End of lines configured by zsh-newuser-install

# reconfig with 'autoload -U compinstall && compinstall'
# The following lines were added by compinstall
zstyle ':completion:*' completer _expand _complete _ignored _match _correct _approximate _prefix
zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' word true
zstyle :compinstall filename '$HOME/.zshrc'
autoload -Uz compinit && compinit
# End of lines added by compinstall

# keep these PROMPT settings in case p10k not working
if [ $(id -u) -eq 0 ]; then
    export PROMPT='%(?.%F{40}√.%F{196}✗)%f [%F{160}%n@%m%f %F{63}%~%f] %F{196}#%f '
else
    export PROMPT='%(?.%F{40}√.%F{196}✗)%f [%F{76}%n@%m%f %F{63}%~%f] %F{40}$%f '
fi
# $?, n jobs, date
export RPROMPT='%(?..$? = %F{196}%?%f,) %(1j.%F{214}%j%f jobs,.) %*'

# which brew > /dev/null 2>&1
if [ -e /usr/local/bin/brew ]; then
    export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
    export PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"
    export PATH="$(brew --prefix gnu-sed)/libexec/gnubin:$PATH"
    export PATH="$(brew --prefix grep)/libexec/gnubin:$PATH"
fi
export PATH=$HOME/.bin:$PATH

if which gls > /dev/null 2>&1; then
    alias ls='gls --color=auto' 
elif ls --version 2>/dev/null | grep coreutils > /dev/null; then
    alias ls='ls --color=auto'  # GNU coreutils
else
    alias ls='ls -G'            # macOS ls
fi
alias ll='ls -lh'
alias lla='ls -lha'
alias du='du -h --max-depth=1'
alias grep='grep --color=auto'

export LSCOLORS=exfxcxdxbxbxbxbxbxbxbx # BSD
export LS_COLORS='no=00;37:fi=00:di=34;40:ln=35;40:so=32;40:pi=33;40:ex=31;40:bd=31;40:cd=31;40:su=31;40:sg=31;40:tw=31;40:ow=31;40:'
# Zsh to use the same colors as ls
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}  

export PAGER=less
export LESS=-R
export LANG=en_US.UTF-8
export EDITOR='vim'
export SYSTEMD_EDITOR='vim'

# extract
alias -s zip="unzip"
alias -s gz="tar -xzvf"
alias -s tgz="tar -xzvf"
alias -s bz2="tar -xjvf"
alias -s xz="tar -xJvf"
alias -s rar="unrar x"
alias -s tar="tar -xvf"
alias -s Z="uncompress"
alias -s 7z="7z x"

alias ping="ping -c3"
alias history="history 0"

which rm2trash > /dev/null 2>&1 && alias trm="rm2trash"

# plugins
source $HOME/.zsh/zsh-256color.zsh
source $HOME/.zsh/zsh-autosuggestions.zsh
source $HOME/.zsh/zsh-syntax-highlighting.zsh
source $HOME/.zsh/zsh-history-substring-search.zsh
# no underline for path
typeset -g ZSH_HIGHLIGHT_STYLES[path]=''
autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
if [ "$(uname -s)" = "Linux" ]; then
    bindkey "$terminfo[kcuu1]" history-substring-search-up
    bindkey "$terminfo[kcud1]" history-substring-search-down
else
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
fi

# homebrew
export HOMEBREW_BOTTLE_DOMAIN=https://chinanet.mirrors.ustc.edu.cn/homebrew-bottles
export HOMEBREW_API_DOMAIN=https://chinanet.mirrors.ustc.edu.cn/homebrew-bottles/api

# sudo & systemd
alias sudo="sudo env \"PATH=$PATH\""
export SYSTEMD_EDITOR=vim 

# logo
#$(dirname $(readlink -f ${(%):-%x}))/bin/screenfetch

# rust & cargo
if [ -d $HOME/.cargo ]; then
    fpath+=~/.zsh/zfunc
    source "$HOME/.cargo/env"
fi

# go
if [ -d /usr/local/go ]; then
    export PATH=/usr/local/go/bin:$PATH
fi
export GOPATH=$HOME/.go
export PATH=$GOPATH/bin:$PATH

# https://github.com/Eugeny/tabby/wiki/Shell-working-directory-reporting
precmd () { echo -n "\x1b]1337;CurrentDir=$(pwd)\x07" }

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
if [ -d ~/.zsh/powerlevel10k ]; then
    [[ -e ~/.p10k.zsh ]] && source ~/.p10k.zsh

    # override default settings: must after .p10k.zsh
    # move context to left prompt 
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon context reporoot vcs_joined repodir_joined newline prompt_char)
    # alter right prompt
    POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(${POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS[@]/context})
    POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS+=( docker_host )
    # always show context
    unset POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_{CONTENT,VISUAL_IDENTIFIER}_EXPANSION
    # show background jobs count 
    POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE=true
    POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE_ALWAYS=true
    POWERLEVEL9K_BACKGROUND_JOBS_VISUAL_IDENTIFIER_EXPANSION='≡'
    # date & time 
    POWERLEVEL9K_TIME_FORMAT='%D{%m-%d %H:%M:%S}'
   
    # load the theme at last
    source ~/.zsh/powerlevel10k/powerlevel10k.zsh-theme 
fi

# show relative path to $HOME
#  => keep code here let me known how to do it
#function zsh_directory_name() {
#    emulate -L zsh
#    [[ $1 == d ]] || return
#    typeset -ga reply=(${2:t} $#HOME)
#    return
#}

# help: search prompt_example in '.p10k.zsh'
function prompt_reporoot() {
    local d="$PWD"
    while [ ! -e "$d/.git" ] && [ "$d" != '/' ]; do d=$(dirname $d); done

    if [ "$d" != '/' ]; then
        typeset -g REPOROOT="$d"
        p10k segment -f "$POWERLEVEL9K_DIR_FOREGROUND" -t "$(basename $REPOROOT)"
    elif [ ! -z "$REPOROOT" ]; then
        unset REPOROOT 
    fi
}

function prompt_repodir() {
    if [ -z "$REPOROOT" ]; then
        p10k segment -f "$POWERLEVEL9K_DIR_FOREGROUND" -t '%~'
    else
        p10k segment -f "$POWERLEVEL9K_DIR_FOREGROUND" -t "$(realpath --relative-base=$REPOROOT $PWD)"
    fi
}

function prompt_docker_host() {
    [ -z "$DOCKER_HOST" ] || p10k segment -f skyblue1 -t "🐳 $DOCKER_HOST 🐳"
}
