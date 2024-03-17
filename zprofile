#!/bin/sh
# PATHs
echo $PATH | grep -Fw "/sbin:" &> /dev/null || export PATH="/sbin:$PATH"

# homebrew & linuxbrew
[ -d /home/linuxbrew ]     && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
[ -x /usr/local/bin/brew ] && eval "$(/usr/local/bin/brew shellenv)"

if which brew &> /dev/null; then
    brewprefix="$(brew --prefix)" # run only once to reduce start time
    export PATH="$brewprefix/opt/coreutils/libexec/gnubin:$PATH"
    export PATH="$brewprefix/opt/gnu-sed/libexec/gnubin:$PATH"
    export PATH="$brewprefix/opt/grep/libexec/gnubin:$PATH"
    export PATH="$brewprefix/opt/gnu-tar/libexec/gnubin:$PATH"
    export PATH="$brewprefix/opt/findutils/libexec/gnubin:$PATH"

    export HOMEBREW_BOTTLE_DOMAIN=https://cache.mtdcy.top/homebrew-bottles
    export HOMEBREW_API_DOMAIN=https://cache.mtdcy.top/homebrew-bottles/api
fi

# rust & cargo
[ -d "$HOME/.cargo" ] && source "$HOME/.cargo/env"

# go
export GOPATH="$HOME/.go"
[ -d /usr/local/go ] && export PATH=/usr/local/go/bin:$PATH
[ -d "$GOPATH" ]     && export PATH=$GOPATH/bin:$PATH

# user PATH: shoud export after other PATH
export PATH=$HOME/.bin:$HOME/.local/bin:$PATH

echo ""

if [ "$(uname -o)" != Darwin ]; then
    sed -e 's/cpu_temp=.*$/cpu_temp="C"/' \
        -e 's/memory_unit=.*$/memory_unit=gib/' \
        -e 's/speed_shorthand=.*$/speed_shorthand=on/' \
        -i $HOME/.config/neofetch/config.conf &> /dev/null || true

    neofetch 2> /dev/null
fi
