#!/bin/bash

info() {
    echo -e "\\033[32m=== $*\\033[39m"
}

echocmd() {
    echo -e "\\033[34m==> $*\\033[39m"
    "$@"
}

info "request root privilege"
sudo true

if which brew; then
    info "Cleanup Homebrew"
    #echocmd brew update
    #echocmd brew upgrade
    echocmd brew cleanup --prune=all
fi

if which docker; then
    info "Cleanup Docker"
    echocmd docker system prune --volumes --force
fi

if which python3; then
    info "Cleanup python3"
    echocmd python3 -m pip cache list
    echocmd python3 -m pip cache purge
fi

if which npm; then
    info "Cleanup npm"
    echocmd npm cache clean --force
fi

if which go; then
    info "Cleanup go"
    echocmd go clean -cache -modcache
fi

if which cargo; then
    info "Cleanup cargo"
    echocmd cargo install cargo-cache
    echocmd cargo cache --autoclean
fi

if which conda; then
    info "Cleanup conda"
    echocmd conda clean --all --yes
fi

if test -d "/Library/Application Support/com.apple.idleassetsd"; then
    info "Cleanup idleassets"
    echocmd find "/Library/Application Support/com.apple.idleassetsd" -type f -name "*.mov" -exec sudo rm -rfv {} \;
fi

if test -d "$HOME/Library/Caches"; then
    info "Cleanup ~/Library/Caches"
    echocmd rm -rf "$HOME/Library/Caches"
fi

if test -d "$HOME/.Trash"; then
    echo 'tell application "Finder" to empty trash' | osascript
fi

# cleanup caches
caches=(
    act
    cmdlets
    "Library/Application Support/typora-user-images"
)

for x in "${caches[@]}"; do
    if test -d "$HOME/.cache/$x"; then
        info "Cleanup .cache $x"
        echocmd sudo rm -rf "$HOME/.cache/$x"
    elif test -d "$HOME/Library/Caches/$x"; then
        info "Cleanup Caches $x"
        echocmd sudo rm -rf "$HOME/Library/Caches/$x"
    fi
done
