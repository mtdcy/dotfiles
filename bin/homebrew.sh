#!/bin/sh

#HOMEBREW=https://github.com/Homebrew
#HOMEBREW_BOTTLES= 

#aliyun: no bottles
#HOMEBREW=https://mirrors.aliyun.com/homebrew

#ustc:
HOMEBREW=https://mirrors.ustc.edu.cn

HOMEBREW_BOTTLES=$HOMEBREW/homebrew-bottles
HOMEBREW_BOTTLES_API=$HOMEBREW_BOTTLES/api

echo "HOMEBREW: $HOMEBREW"
echo "HOMEBREW_BOTTLES: $HOMEBREW_BOTTLES"
echo "HOMEBREW_API_DOMAIN: $HOMEBREW_BOTTLES_API"

export HOMEBREW_BREW_GIT_REMOTE=$HOMEBREW/brew.git
export HOMEBREW_CORE_GIT_REMOTE=$HOMEBREW/homebrew-core.git
export HOMEBREW_BOTTLE_DOMAIN=$HOMEBREW_BOTTLES
export HOMEBREW_API_DOMAIN=$HOMEBREW_BOTTLES_API

which brew > /dev/null
if [ $? -ne 0 ]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    #git clone --depth=1 $HOMEBREW/install.git brew-install &&
    #/bin/bash brew-install/install.sh &&
    #rm -rf brew-install
fi

# test again
which brew > /dev/null || exit 1

git -C "$(brew --repo)" remote set-url origin $HOMEBREW/brew.git
git -C "$(brew --repo homebrew/core)" remote set-url origin $HOMEBREW/homebrew-core.git

brew update 
brew upgrade --force # --verbose

# enable homebrew cask
HOMEBREW_CASK=$(brew --repo homebrew/cask)
if [ ! -e "$HOMEBREW_CASK" ]; then
    #brew tap homebrew/cask
    git clone $HOMEBREW/homebrew-cask.git $HOMEBREW_CASK
else
    git -C $HOMEBREW_CASK remote set-url origin $HOMEBREW/homebrew-cask.git
fi

# something wrong with cask versions
#HOMEBREW_CASK_VERSIONS=$(brew --repo homebrew/cask-versions)
#if [ ! -e "$HOMEBREW_CASK_VERSIONS" ]; then 
#    #brew tap homebrew/cask-versions
#    git clone $HOMEBREW/homebrew-cask-versions.git $HOMEBREW_CASK_VERSIONS
#else
#    git -C $HOMEBREW_CASK_VERSIONS remote set-url origin $HOMEBREW/homebrew-cask-versions.git
#fi

brew cleanup

brew install coreutils gnu-sed grep awk 
#brew install google-chrome

SHRC=$HOME/.zshrc
grep HOMEBREW_BOTTLE_DOMAIN $SHRC > /dev/null
if [ $? -eq 0 ]; then
    gsed -i "s,HOMEBREW_BOTTLE_DOMAIN=[^;]*,HOMEBREW_BOTTLE_DOMAIN=$HOMEBREW_BOTTLES," $SHRC
else
    echo "export HOMEBREW_BOTTLE_DOMAIN=$HOMEBREW_BOTTLES" >> $SHRC
fi

grep HOMEBREW_API_DOMAIN $SHRC > /dev/null
if [ $? -eq 0 ]; then
    gsed -i "s,HOMEBREW_API_DOMAIN=[^;]*,HOMEBREW_API_DOMAIN=$HOMEBREW_BOTTLES_API," $SHRC 
else
    echo "export HOMEBREW_API_DOMAIN=$HOMEBREW_BOTTLES_API" >> $SHRC 
fi
