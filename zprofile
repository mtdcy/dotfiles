#!/bin/sh

umask 0022

MIRRORS=https://mirrors.mtdcy.top:8443

# PATHs
echo $PATH | grep -Fw "/sbin:" &> /dev/null || export PATH="/sbin:$PATH"

# homebrew & linuxbrew
[ -d /home/linuxbrew ]     && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
[ -x /usr/local/bin/brew ] && eval "$(/usr/local/bin/brew shellenv)"

[ -d /opt/homebrew ] && export PATH=/opt/homebrew/bin:$PATH

if which brew &> /dev/null; then
    brewprefix="$(brew --prefix)" # run only once to reduce start time
    [ -d "$brewprefix/opt/coreutils"    ] && export PATH="$brewprefix/opt/coreutils/libexec/gnubin:$PATH"
    [ -d "$brewprefix/opt/gnu-sed"      ] && export PATH="$brewprefix/opt/gnu-sed/libexec/gnubin:$PATH"
    [ -d "$brewprefix/opt/grep"         ] && export PATH="$brewprefix/opt/grep/libexec/gnubin:$PATH"
    [ -d "$brewprefix/opt/gnu-tar"      ] && export PATH="$brewprefix/opt/gnu-tar/libexec/gnubin:$PATH"
    [ -d "$brewprefix/opt/findutils"    ] && export PATH="$brewprefix/opt/findutils/libexec/gnubin:$PATH"

    export HOMEBREW_BOTTLE_DOMAIN=$MIRRORS/homebrew-bottles
    export HOMEBREW_API_DOMAIN=$MIRRORS/homebrew-bottles/api
    export HOMEBREW_NO_AUTO_UPDATE=true
fi

# rust & cargo
if [ -d "$HOME/.cargo" ]; then
    export RUSTUP_DIST_SERVER=$MIRRORS/rust-static
    export RUSTUP_UPDATE_ROOT=$MIRRORS/rust-static/rustup
    [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
    [ -d "$HOME/.cargo/bin" ] && export PATH="$HOME/.cargo/bin:$PATH"
fi

# go
[ -d /usr/local/go ] && export PATH=/usr/local/go/bin:$PATH
if which go &> /dev/null; then
    export GOPATH="$HOME/.go"
    export GOPROXY="$MIRRORS/gomods,direct"
    mkdir -p "$GOPATH"

    export PATH=$GOPATH/bin:$PATH
fi

# luarocks
[ -d "$HOME/.luarocks" ] && export PATH=$HOME/.luarocks/bin:$PATH

# deno
[ -f "$HOME/.deno/env" ] && source "$HOME/.deno/env"

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

unset MIRRORS
