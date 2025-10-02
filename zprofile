#!/bin/sh

umask 0022

MIRRORS=https://mirrors.mtdcy.top:8443

# PATHs
echo $PATH | grep -Fw "/sbin:" &> /dev/null || export PATH="/sbin:$PATH"

# homebrew & linuxbrew
_repo=(
    /home/linuxbrew
    /usr/local
    /opt/homebrew
)

for x in "${_repo[@]}"; do
    [ -x "$x/bin/brew" ] || continue;
    eval -- "$("$x/bin/brew" shellenv)" && break
done
unset _repo

if test -n "$HOMEBREW_PREFIX"; then
    gnubin=( coreutils gnu-sed gawk grep gnu-tar findutils )
    for x in "${gnubin[@]}"; do
        [ -d "$HOMEBREW_PREFIX/opt/$x/libexec" ] && export PATH="$HOMEBREW_PREFIX/opt/$x/libexec/gnubin:$PATH"
    done
    unset gnubin

    export HOMEBREW_BREW_GIT_REMOTE="$MIRRORS/brew.git"
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

# cmdlets
export CMDLETS_MAIN_REPO=$MIRRORS/cmdlets/latest

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
