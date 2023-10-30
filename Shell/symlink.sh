#!/bin/bash
#
cd $(dirname $0) && cd $(pwd -P)
. lib.sh

function usage {
    cat << EOF
setup.sh [options] 
    +bash   - link bash profiles to $HOME
    +zsh    - link zsh profiles to $HOME
    +vim    - link vim profiles to $HOME
    +bin    - link bin to $HOME/.bin
    +all    - link all dotfiles
EOF
}

DOTFILES=(
    "bashrc"
    "zshrc zsh zfunc"
    "vimrc vim"
    "bin"
)

BASH_IDX=0
ZSH_IDX=1
VIM_IDX=2
BIN_IDX=3

# 
# link_target <idx>
function link_target {
    for file in ${DOTFILES[$1]}; do 
        link=$HOME/.$file
        [ -e "$link" ] && rm -rf $link
        ln -svf $(pwd -P)/$file $link
    done
}

echo $@ | grep "+all" > /dev/null
if [ $? -eq 0 ]; then 
    for ((i=0; i<${#DOTFILES[@]}; ++i )); do
        link_target $i
    done
else
    for par in "$@"; do
        case "$par" in
            "+bash")
                link_target $BASH_IDX 
                ;;
            "+zsh")
                link_target $ZSH_IDX 
                ;;
            "+vim")
                link_target $VIM_IDX 
                ;;
            "+bin")
                link_target $BIN_IDX 
                ;;
            *)
                usage 
                ;;
        esac
    done
fi
