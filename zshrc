# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Copyright (c) 2014, Chen Fang mtdcy.chen@gmail.com

#zmodload zsh/zprof

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
#if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
#fi

# reconfig with 'autoload -U zsh-newuser-install && zsh-newuser-install'
# Lines configured by zsh-newuser-install
HISTFILE=$HOME/.zsh/history
HISTSIZE=10000
SAVEHIST=10000
setopt autocd beep extendedglob histfindnodups histignorealldups
setopt nomatch notify

# vi mode
#bindkey -v
# End of lines configured by zsh-newuser-install

# reconfig with 'autoload -U compinstall && compinstall'

# The following lines were added by compinstall

zstyle ':completion:*' completer _expand _complete #_correct
zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' max-errors 3 numeric
zstyle ':completion:*' word true
zstyle :compinstall filename "$HOME/.zshrc"

autoload -Uz compinit
compinit
# End of lines added by compinstall

# keep these PROMPT settings in case p10k not working
if [ $(id -u) -eq 0 ]; then
    export PROMPT='%(?.%F{40}√.%F{196}✗)%f [%F{160}%n@%m%f %F{63}%~%f] %F{196}#%f '
else
    export PROMPT='%(?.%F{40}√.%F{196}✗)%f [%F{76}%n@%m%f %F{63}%~%f] %F{40}$%f '
fi
# $?, n jobs, date
export RPROMPT='%(?..$? = %F{196}%?%f,) %(1j.%F{214}%j%f jobs,.) %*'

# plugins
fpath+=("$HOME/.zsh/zsh-completions")
fpath+=("$HOME/.zfunc")

source $HOME/.zsh/zsh-256color.zsh
source $HOME/.zsh/zsh-autosuggestions.zsh
source $HOME/.zsh/zsh-syntax-highlighting.zsh
source $HOME/.zsh/zsh-history-substring-search.zsh
source $HOME/.zsh/zsh-iterm2-shell-integration.zsh

# autosuggestions: Ctrl+l
bindkey '^l' autosuggest-accept
typeset -g ZSH_AUTOSUGGEST_USE_ASYNC=1
typeset -g ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd)

# no underline for path
typeset -g ZSH_HIGHLIGHT_STYLES[path]=''

if [ "$(uname -s)" = "Linux" ]; then
    bindkey "$terminfo[kcuu1]" history-substring-search-up
    bindkey "$terminfo[kcud1]" history-substring-search-down
else
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
fi

# ** Outdated? history-search-end works well without this **
# https://github.com/zsh-users/zsh/blob/master/Functions/Zle/history-search-end
#autoload -U history-search-end
#zle -N history-beginning-search-backward-end history-search-end
#zle -N history-beginning-search-forward-end history-search-end

# https://github.com/Eugeny/tabby/wiki/Shell-working-directory-reporting
precmd () { echo -n "\x1b]1337;CurrentDir=$(pwd)\x07" }

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
if [ -d ~/.zsh/powerlevel10k ]; then
    [[ -e ~/.p10k.zsh ]] && source ~/.p10k.zsh

    # override default settings: must after .p10k.zsh
    # set left prompt
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(term os_icon_joined reporoot vcs_joined repodir_joined newline prompt_char)
    # alter right prompt
    #POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(${POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS[@]/context})
    POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS+=( remote_host )
    # always show context
    #unset POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_{CONTENT,VISUAL_IDENTIFIER}_EXPANSION
    # show background jobs count
    POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE=true
    POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE_ALWAYS=true
    POWERLEVEL9K_BACKGROUND_JOBS_VISUAL_IDENTIFIER_EXPANSION='≡'
    # date & time
    #POWERLEVEL9K_TIME_FORMAT='%D{%m-%d %H:%M:%S}'
    POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'

    # load the theme at last
    source ~/.zsh/powerlevel10k/powerlevel10k.zsh-theme
    # override colors
    POWERLEVEL9K_DIR_FOREGROUND='skyblue1'

    POWERLEVEL9K_CONTEXT_FOREGROUND='yellow'
    POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND='red'
    POWERLEVEL9K_CONTEXT_REMOTE_FOREGROUND='yellow'
    POWERLEVEL9K_CONTEXT_REMOTE_SUDO_FOREGROUND='red'
    unset POWERLEVEL9K_CONTEXT_BACKGROUND
    unset POWERLEVEL9K_CONTEXT_{ROOT,REMOTE,REMOTE_SUDO}_BACKGROUND
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
function prompt_term() {
    [ -z "$TMUX" ] || p10k segment \
        -f "$POWERLEVEL9K_OS_ICON_FOREGROUND" \
        -b "$POWERLEVEL9K_OS_ICON_BACKGROUND" \
        -t '⧉' #'⌨'
}

function prompt_reporoot() {
    local d="$PWD"
    while [ ! -e "$d/.git" ] && [ "$d" != '/' ]; do d=$(dirname $d); done

    if [ "$d" != '/' ]; then
        typeset -g REPOROOT="$d"
        p10k segment \
            -f "$POWERLEVEL9K_DIR_FOREGROUND" \
            -b "$POWERLEVEL9K_DIR_BACKGROUND" \
            -t "$(basename $REPOROOT)"
    elif [ ! -z "$REPOROOT" ]; then
        unset REPOROOT
    fi
}

function prompt_repodir() {
    if [ -z "$REPOROOT" ]; then
        p10k segment \
            -f "$POWERLEVEL9K_DIR_FOREGROUND" \
            -b "$POWERLEVEL9K_DIR_BACKGROUND" \
            -t '%~'
    else
        p10k segment \
            -f "$POWERLEVEL9K_DIR_FOREGROUND" \
            -b "$POWERLEVEL9K_DIR_BACKGROUND" \
            -t "$(realpath --relative-base=$REPOROOT $PWD)"
    fi
}

function prompt_remote_host() {
    [ -z "$DOCKER_HOST" ]   || { p10k segment -f skyblue1 -t "🐳 $DOCKER_HOST 🐳"   ; return; }
    [ -z "$DOCKER_IMAGE" ]  || { p10k segment -f skyblue1 -t "⌨ $DOCKER_IMAGE ⌨"  ; return; }
    [ -z "$REMOTE_HOST" ]   || { p10k segment -f skyblue1 -t "⌨ $REMOTE_HOST ⌨"     ; return; }
}

# COLORS
export LSCOLORS=exfxcxdxbxbxbxbxbxbxbx # BSD
export LS_COLORS='no=00;37:fi=00:di=34;40:ln=35;40:so=32;40:pi=33;40:ex=31;40:bd=31;40:cd=31;40:su=31;40:sg=31;40:tw=31;40:ow=31;40:'
# Zsh to use the same colors as ls
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# ENVs
export PAGER=less
export LESS=-R
export LANG=en_US.UTF-8
#export EDITOR='vim' # => will enable vi mode for zsh

# for Tabby
export PROMPT_COMMAND='echo -ne "\033]0;${PWD}\007"'

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

source "$HOME/.zsh/functions.sh"

# DEBUG
timezsh() { /usr/bin/time $SHELL -i -c exit; }
#zprof
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/mtdcy/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
