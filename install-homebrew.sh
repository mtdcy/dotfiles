#!/bin/bash

cd $(dirname "$0")

# compare version and print it
brewver() { brew --version | awk -F' ' -v ver=$1 '$2 >= ver {print $2}'; }

#HOMEBREW=https://github.com/Homebrew
#HOMEBREW=https://mirrors.aliyun.com/homebrew aliyun: no bottles
HOMEBREW=${HOMEBREW:-https://mirrors.ustc.edu.cn}

echo "HOMEBREW: $HOMEBREW"
export HOMEBREW_BOTTLE_DOMAIN=$HOMEBREW/homebrew-bottles
export HOMEBREW_API_DOMAIN=$HOMEBREW/homebrew-bottles/api

which brew || /bin/bash -c "$(curl -fsSL https://mirrors.ustc.edu.cn/misc/brew-install.sh)"

# test again
which brew || exit 1
which git  || brew install git

git -C "$(brew --repo)" remote set-url origin $HOMEBREW/brew.git

[ "$(brewver 4.0)" = "" ] && {
    git -C "$(brew --repo homebrew/core)" remote set-url origin $HOMEBREW/homebrew-core.git 
}

# enable homebrew cask
[ "$(brewver 4.0)" = "" ] && {
    git -C "$(brew --repo homebrew/cask)" remote set-url origin "$HOMEBREW/homebrew-cask.git" ||
    brew tap --custom-remote --force-auto-update homebrew/cask "$HOMEBREW/homebrew-cask.git"
}

git -C "$(brew --repo homebrew/cask-versions)" remote set-url origin "$HOMEBREW/homebrew-cask-versions.git" ||
brew tap --custom-remote --force-auto-update homebrew/cask-versions "$HOMEBREW/homebrew-cask-versions.git"

# enable homebrew service 
git -C "$(brew --repo homebrew/services)" remote set-url origin "$HOMEBREW/homebrew-services.git" ||
brew tap --custom-remote --force-auto-update homebrew/services "https://mirrors.ustc.edu.cn/homebrew-services.git"

brew update 
#brew upgrade --force --verbose
brew cleanup

SHRC=()
[ -e "$HOME/.bashrc" ] && SHRC+=("$HOME/.bashrc")
[ -e "$HOME/.zshrc" ]  && SHRC+=("$HOME/.zshrc")
[ -e "$PWD/bashrc" ]   && SHRC+=("$PWD/bashrc")
[ -e "$PWD/zshrc" ]    && SHRC+=("$PWD/zshrc")

for i in "${SHRC[@]}"; do
    grep "export HOMEBREW_BOTTLE_DOMAIN=" "$i" || 
    echo "export HOMEBREW_BOTTLE_DOMAIN=$HOMEBREW_BOTTLE_DOMAIN" >> "$i"

    grep "export HOMEBREW_API_DOMAIN=" "$i" || 
    echo "export HOMEBREW_API_DOMAIN=$HOMEBREW_API_DOMAIN" >> "$i"

    sed \
        -e "s|\(^.*HOMEBREW_BOTTLE_DOMAIN=\).*$|\1$HOMEBREW_BOTTLE_DOMAIN|" \
        -e "s|\(^.*HOMEBREW_API_DOMAIN=\).*$|\1$HOMEBREW_API_DOMAIN|" \
        -i "$i"
done
