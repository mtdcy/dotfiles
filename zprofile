#!/bin/sh

umask 0022

# PATHs
echo $PATH | grep -Fw "/sbin:" &> /dev/null || export PATH="/sbin:$PATH"

# homebrew & linuxbrew
[ -d /home/linuxbrew ]     && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
[ -x /usr/local/bin/brew ] && eval "$(/usr/local/bin/brew shellenv)"

if which brew &> /dev/null; then
    brewprefix="$(brew --prefix)" # run only once to reduce start time
    [ -d "$brewprefix/opt/coreutils"    ] && export PATH="$brewprefix/opt/coreutils/libexec/gnubin:$PATH"
    [ -d "$brewprefix/opt/gnu-sed"      ] && export PATH="$brewprefix/opt/gnu-sed/libexec/gnubin:$PATH"
    [ -d "$brewprefix/opt/grep"         ] && export PATH="$brewprefix/opt/grep/libexec/gnubin:$PATH"
    [ -d "$brewprefix/opt/gnu-tar"      ] && export PATH="$brewprefix/opt/gnu-tar/libexec/gnubin:$PATH"
    [ -d "$brewprefix/opt/findutils"    ] && export PATH="$brewprefix/opt/findutils/libexec/gnubin:$PATH"

    export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.mtdcy.top/homebrew-bottles
    export HOMEBREW_API_DOMAIN=https://mirrors.mtdcy.top/homebrew-bottles/api
    export HOMEBREW_NO_AUTO_UPDATE=true
fi

# rust & cargo
if [ -d "$HOME/.cargo" ]; then
    export RUSTUP_DIST_SERVER=https://mirrors.mtdcy.top/rust-static
    export RUSTUP_UPDATE_ROOT=https://mirrors.mtdcy.top/rust-static/rustup
    . "$HOME/.cargo/env"
fi

# go
export GOPATH="$HOME/.go"
[ -d /usr/local/go ] && export PATH=/usr/local/go/bin:$PATH
[ -d "$GOPATH" ]     && export PATH=$GOPATH/bin:$PATH

# luarocks
[ -d "$HOME/.luarocks" ] && export PATH=$HOME/.luarocks/bin:$PATH

# deno
[ -d "$HOME/.deno" ] && source "$HOME/.deno/env"

if [ -d "$HOME/.Miniconda3" ]; then
    if [ -f "$HOME/.Miniconda3/etc/profile.d/conda.sh" ]; then
        . "$HOME/.Miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/.Miniconda3/bin:$PATH"
    fi
fi

# user PATH: shoud export after other PATH
export PATH=$HOME/.bin:$HOME/.local/bin:$PATH

# custom data path
if test -e "$HOME/Data"; then
    export OLLAMA_MODELS="$HOME/Data/ollama"
fi

# default locales
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
