# Lines configured by zsh-newuser-install
HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
export HISTTIMEFORMAT="[%F %T] "
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt autocd extendedglob nomatch notify
bindkey -v
# End of lines configured by zsh-newuser-install

# The following lines were added by compinstall
zstyle ':completion:*' completer _complete _ignored
zstyle :compinstall filename '$HOME/.zshrc'
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
autoload -Uz compinit && compinit
# End of lines added by compinstall

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

ls --version 2>/dev/null | grep coreutils > /dev/null 
if [ $? -eq 0 ]; then
    alias ls='ls --color=auto'  # GNU coreutils
else
    alias ls='ls -G'            # macOS ls
fi
alias ll='ls -lh'
alias lla='ls -lha'
alias du='du -h --max-depth=1'

export LS_COLORS='di=34;40:ln=35;40:so=32;40:pi=33;40:ex=31;40:bd=31;40:cd=31;40:su=31;40:sg=31;40:tw=31;40:ow=31;40:'
export LSCOLORS=exfxcxdxbxbxbxbxbxbxbx # BSD
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

# sudo preserve PATH
alias sudo="sudo env \"PATH=$PATH\""

which rm2trash > /dev/null 2>&1 && alias trm="rm2trash"

# plugins
source $HOME/.zsh/zsh-256color.zsh
source $HOME/.zsh/zsh-autosuggestions.zsh
source $HOME/.zsh/zsh-history-substring-search.zsh
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

# rust & cargo
if [ -d $HOME/.cargo ]; then
    fpath+=~/.zsh/zfunc
    source "$HOME/.cargo/env"
fi

# homebrew
export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.aliyun.com/homebrew/homebrew-bottles
export HOMEBREW_API_DOMAIN=https://mirrors.aliyun.com/homebrew/homebrew-bottles/api

# systemd
export SYSTEMD_EDITOR=vim 

# logo
#$(dirname $(readlink -f ${(%):-%x}))/bin/screenfetch

if [ -d /usr/local/go ]; then
    export PATH=/usr/local/go/bin:$PATH
fi
export GOPATH=$HOME/.go
export PATH=$GOPATH/bin:$PATH

# https://github.com/Eugeny/tabby/wiki/Shell-working-directory-reporting
precmd () { echo -n "\x1b]1337;CurrentDir=$(pwd)\x07" }

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[ -d ~/.zsh/powerlevel10k ] && source ~/.zsh/powerlevel10k/powerlevel10k.zsh-theme 

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
