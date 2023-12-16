#!/bin/bash 
#

for i in bin bashrc zsh zshrc; do
    ln -svfT $PWD/$i $HOME/.$i 
done

cd nvim && ./install.sh 
