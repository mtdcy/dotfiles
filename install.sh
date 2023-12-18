#!/bin/bash 
#

pkg='brew'
which apt && pkg='apt'

which zsh || $pkg install zsh
which vim || $pkg install vim

chsh -s "$(which zsh)"

EDITOR="$(which vim)"
which nvim && EDITOR="$(which nvim)"

if which update-alternatives; then
    sudo update-alternatives --install "$(which editor)" editor "$EDITOR"
    sudo update-alternatives --set editor "$EDITOR"
fi

git update-index --assume-unchanged zsh/history 
for i in bin bashrc zsh zshrc; do
    ln -svfT $PWD/$i $HOME/.$i 
done

if [ "$1" = "all" ]; then
    git submodule update --init --recursive
    git submodule update --recursive --remote
    cd nvim && ./install.sh 
fi
