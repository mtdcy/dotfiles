#!/bin/bash -e

cd "$(dirname "$0")" || exit 1

instdir="$(pwd -P)"

workdir="$(mktemp -d)"
trap "rm -rf $workdir" EXIT

cd "$workdir" || exit 1

git clone --depth 1 https://github.com/zsh-users/zsh-completions.git 

mkdir -pv "$instdir/zsh-completions"
cp -fv zsh-completions/src/_* "$instdir/zsh-completions/"

# docker completion
curl -sL -o "$instdir/zsh-completions/_docker" https://raw.githubusercontent.com/docker/cli/master/contrib/completion/zsh/_docker

# shell integration
curl -sL -o "$instdir/zsh-iterm2-shell-integration.zsh" https://iterm2.com/shell_integration/zsh
