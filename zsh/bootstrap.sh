#!/bin/bash -e

cd "$(dirname "$0")" || exit 1

INSTDIR="$(pwd -P)"

WORKDIR="$(mktemp -d)"
trap "rm -rf $WORKDIR" EXIT

cd "$WORKDIR" || exit 1

git clone --depth 1 https://github.com/zsh-users/zsh-completions.git

mkdir -pv "$INSTDIR/completions"
cp -fv zsh-completions/src/_* "$INSTDIR/completions/"

# docker completion
curl -sL -o "$INSTDIR/completions/_docker" https://raw.githubusercontent.com/docker/cli/master/contrib/completion/zsh/_docker

# shell integration
curl -sL -o "$INSTDIR/zsh-iterm2-shell-integration.zsh" https://iterm2.com/shell_integration/zsh

if which openclaw; then
    { 
        echo "#compdef _openclaw_root_completion openclaw"
        openclaw completion -s zsh 
    } > "$INSTDIR/completions/_openclaw"
fi
