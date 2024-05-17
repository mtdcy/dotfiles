#!/bin/bash 
# 
# vim:ts=4:sw=4:ai:foldmethod=marker:foldlevel=0:fmr=#>>,#<<
set -e

cd $(dirname "$0") || exit 1
. bin/xlib.sh 

[ -z "$MIRRORS" ] && 
    curl -o /dev/null https://mirrors.mtdcy.top && 
    MIRRORS=https://mirrors.mtdcy.top

MIRRORS=${MIRRORS:-https://mirrors.ustc.edu.cn}
INSTALL_HOMEBREW=${INSTALL_HOMEBREW:-0}

#>> install programs
if [ "$(uname)" = "Darwin" ] || [ "$INSTALL_HOMEBREW" -eq 1 ]; then
    #which brew || ./install-homebrew.sh "$MIRRORS" || exit 1
    MIRRORS="$MIRRORS" ./install-homebrew.sh || exit 1

    # install gnu tools
    for i in coreutils gnu-sed grep awk; do
        brew --prefix "$i" || brew install "$i"
    done

    pm='NONINTERACTIVE=1 brew install'
elif which brew; then
    xlog info "linuxbrew present"
    pm='NONINTERACTIVE=1 brew install'
elif [ -f /etc/apt/sources.list ]; then
    #sudo apt install auto-apt-proxy
    #auto-apt-proxy ||
    #sudo sed \
    #    -e "/^deb/ s|http[s]*://[a-z\.]*/|$MIRRORS/|g" \
    #    -i /etc/apt/sources.list
    sudo apt update

    pm='sudo apt install -y'
fi

if which brew; then
    export PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"
    export PATH="$(brew --prefix gnu-sed)/libexec/gnubin:$PATH"
    export PATH="$(brew --prefix grep)/libexec/gnubin:$PATH"
fi
## its safe to use gnu tools from now on ##

#>> install files
git update-index --assume-unchanged zsh/history 
for i in bin bashrc zsh zshrc zprofile vim vimrc tmux.conf; do
    ln -svfT "$PWD/$i" "$HOME/.$i"
done

# install fonts instead of create symlinks.
if [ "$(uname)" = "Darwin" ]; then
    mkdir -pv ~/Library/Fonts 
    cp -fv fonts/* ~/Library/Fonts/
else
    mkdir -pv ~/.local/share/fonts
    cp -fv fonts/* ~/.local/share/fonts/
fi
#<<

[ -z "$pm" ] && { xlog error "Please set package manager first."; exit 1; }

# install host tools
for i in zsh vim git wget tree; do
    #which "$i" || eval -- $pm "$i"
    eval -- $pm "$i"
done


#<<

#>> default settings
$SHELL --version | grep 'zsh 5' || chsh -s "$(which zsh)"

EDITOR="$(which vim)"
if which update-alternatives && which editor; then
    sudo update-alternatives --install "$(which editor)" editor "$(readlink -f $EDITOR)" 100
    sudo update-alternatives --set editor "$(readlink -f $EDITOR)"
fi
#<<

#>> git:
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

git config --global --replace-all alias.pl      "pull --rebase --recurse-submodules"
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
#<<

#>> submodules: 
git submodule update --init --recursive || true
git submodule update --remote --merge || true

# install nvim 
[ "$1" = "all" ] && MIRRORS=$MIRRORS ./nvim/install.sh 
#<<

#>> applications:
if [ "$(uname)" = "Darwin" ]; then
    defaults import com.googlecode.iterm2 iterm2/com.googlecode.iterm2.plist
fi
#<<
