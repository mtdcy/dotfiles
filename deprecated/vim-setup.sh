#!/bin/bash

cd $(dirname $0)

# vim
ln -sfv  $(pwd)/vimrc   $HOME/.vimrc 
ln -sfvT $(pwd)/vim     $HOME/.vim 

if [ "$1" = "nvim" ]; then
	#pip=$(which pip3 2>/dev/null || which pip)
	#$pip show neovim > /dev/null 2>&1 || $pip install neovim 

    ln -sfvT $(pwd)/nvim    $HOME/.config/nvim 
fi
