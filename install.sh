#!/bin/bash 
#

git submodule update --init --recursive
git submodule update --recursive --remote
git update-index --assume-unchanged zsh/history 

for i in bin bashrc zsh zshrc; do
    ln -svfT $PWD/$i $HOME/.$i 
done

cd nvim && ./install.sh 
