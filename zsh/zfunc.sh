#!/bin/bash -e

cd "$(dirname "$0")" || exit 1

INSTDIR="$(pwd -P)"

WORKDIR="$(mktemp -d)"
trap "rm -rf $WORKDIR" EXIT

cd "$WORKDIR" || exit 1

git clone --depth 1 https://github.com/zsh-users/zsh-completions.git

mkdir -pv "$INSTDIR/zsh-completions"
cp -fv zsh-completions/src/_* "$INSTDIR/zsh-completions/"

# docker completion
curl -sL -o "$INSTDIR/zsh-completions/_docker" https://raw.githubusercontent.com/docker/cli/master/contrib/completion/zsh/_docker

# shell integration
curl -sL -o "$INSTDIR/zsh-iterm2-shell-integration.zsh" https://iterm2.com/shell_integration/zsh

which openclaw && openclaw completion -s zsh > "$INSTDIR/zsh-completions/_openclaw"
