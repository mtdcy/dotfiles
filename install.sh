#!/bin/bash 

cd $(dirname "$0") || exit 1
. bin/xlib.sh 

MIRRORS=${1:-https://chinanet.mirrors.ustc.edu.cn}

# pre-install
if [ "$(uname)" = "Darwin" ]; then
    which brew || ./install-homebrew.sh "$MIRRORS" || exit 1
    for i in coreutils gnu-sed grep awk; do
        brew --prefix "$i" || brew install "$i"
    done
elif [ -f /etc/apt/sources.list ]; then
    sudo apt install auto-apt-proxy
    auto-apt-proxy ||
    sudo sed \
        -e "/^deb/ s|http[s]*://[a-z\.]*/|$MIRRORS/|g" \
        -i /etc/apt/sources.list
    sudo apt update
fi

which brew && pm='brew'
which apt  && pm='apt'
[ -z "$pm" ] && { xlog error "Please set package manager first."; exit 1; }

for i in zsh vim git wget tree; do
    which "$i" || $pm install "$i"
done

# switch shell to zsh
$SHELL --version | grep 'zsh 5' || chsh -s "$(which zsh)"

EDITOR="$(which vim)"
if which update-alternatives; then
    sudo update-alternatives --install "$(which editor)" editor "$EDITOR" 100
    sudo update-alternatives --set editor "$EDITOR"
fi

# symlinks:
git update-index --assume-unchanged zsh/history 
for i in bin bashrc zsh zshrc vim vimrc; do
    ln -svfT "$PWD/$i" "$HOME/.$i"
done

# git
which less &&
git config --global --replace-all core.pager    "less -F -X" ||
git config --global --replace-all core.pager    "more"
git config --global --replace-all pull.rebase   true
git config --global --replace-all push.default  simple
git config --global --replace-all core.editor   vim
git config --global --replace-all diff.tool     vimdiff
git config --global --replace-all core.autocrlf false

git config --global --replace-all core.mergeoptions --no-edit
git config --global --replace-all mergetool.prompt false
git config --global --replace-all merge.tool vimdiff
git config --global --replace-all merge.conflictstyle diff3
git config --global --replace-all core.excludesfile '*.swp'

git config --global --replace-all alias.pl      "pull --rebase"
git config --global --replace-all alias.st      status 
git config --global --replace-all alias.co      checkout
git config --global --replace-all alias.ci      commit
git config --global --replace-all alias.br      branch 
git config --global --replace-all alias.cp      "cherry-pick --no-ff -x" 
git config --global --replace-all alias.lg      "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cn - %ci)'"
git config --global --replace-all alias.lg1     "log -n 1 --color --name-status --parents"
git config --global --replace-all alias.lga     "log --color --graph --all --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cn - %cr)'"

git config --global --get user.name     || git config --global --replace-all user.name  "$(read -p 'user.name: '; echo $REPLY)"
git config --global --get user.email    || git config --global --replace-all user.email "$(read -p 'user.email: '; echo $REPLY)"
