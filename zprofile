#!/bin/sh

umask 0022

MIRRORS=https://mirrors.mtdcy.top
if ! curl -fsI --connect-timeout 1 "$MIRRORS" -o /dev/null; then
    MIRRORS=https://mirrors.ustc.edu.cn
else
    export CMDLETS_MAIN_REPO=$MIRRORS/cmdlets/latest
fi

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
    _gnubin=( coreutils gnu-sed gawk grep gnu-tar findutils )
    for x in "${_gnubin[@]}"; do
        [ -d "$HOMEBREW_PREFIX/opt/$x/libexec" ] && export PATH="$HOMEBREW_PREFIX/opt/$x/libexec/gnubin:$PATH"
    done
    unset _gnubin

    export HOMEBREW_BREW_GIT_REMOTE="$MIRRORS/brew.git"
    export HOMEBREW_BOTTLE_DOMAIN=$MIRRORS/homebrew-bottles
    export HOMEBREW_API_DOMAIN=$MIRRORS/homebrew-bottles/api
    export HOMEBREW_NO_AUTO_UPDATE=true
fi

# rust & cargo
if which rustup &>/dev/null || which cargo &>/dev/null; then
    export CARGO_HOME="$HOME/.cargo"
    mkdir -p "$CARGO_HOME/bin"
    export PATH="$CARGO_HOME/bin:$PATH"

    [ -f "$CARGO_HOME/env" ] && . "$CARGO_HOME/env"

    export RUSTUP_HOME="$HOME/.rustup"
    export RUSTUP_DIST_SERVER=$MIRRORS/rust-static
    export RUSTUP_UPDATE_ROOT=$MIRRORS/rust-static/rustup
fi

# go
[ -d /usr/local/go ] && export PATH=/usr/local/go/bin:$PATH
if which go &> /dev/null; then
    export GOPATH="$HOME/.go"
    export GOPROXY="$MIRRORS/gomods"
    export PATH=$GOPATH/bin:$PATH
    mkdir -p "$GOPATH"
fi

# luarocks
if which luarocks &>/dev/null; then
    mkdir -p "$HOME/.luarocks"
    export PATH=$HOME/.luarocks/bin:$PATH
fi

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
