#!/bin/bash
LANG=en_US.UTF-8

pushd "$(dirname "$0")"

error() { echo -e "\\033[31m$*\\033[39m"; }
info()  { echo -e "\\033[32m$*\\033[39m"; }
warn()  { echo -e "\\033[33m$*\\033[39m"; }


check() {
    case "$1" in
        http://*|https://*)
            curl --fail -sIL -o /dev/null "$1"
            ;;
    esac
}

if [ "$0" = install ] || [ "$1" = install ]; then
    if [ -d "$HOME/.files" ]; then
        git -C "$HOME/.files" pull --rebase
    else
        git clone https://git.mtdcy.top/mtdcy/dotfiles.git "$HOME/.files"
    fi
    exec "$HOME/.files/install.sh"
fi

#>> Install cmdlets.sh and GNU utils
info "install cmdlets.sh"
if check https://git.mtdcy.top/mtdcy/cmdlets; then
    curl -o bin/cmdlets.sh -sL https://git.mtdcy.top/mtdcy/cmdlets/raw/branch/main/cmdlets.sh
else
    curl -o bin/cmdlets.sh -sL https://raw.githubusercontent.com/mtdcy/cmdlets/main/cmdlets.sh
fi

utils=(sed grep awk ln)
for x in "${utils[@]}"; do
    "$x" --version | grep -qFw GNU || {
        info "install gnu $x"
        bash bin/cmdlets.sh install "$x"
    }
done

# always copy in msys2
[[ "$OSTYPE" =~ msys ]] && LN='cp -rfv' || LN='ln -svfT'
#<< its safe to use gnu tools from now on ##

#>> install dotfiles
# 'fatal: Unable to mark file zsh/history'
git update-index --assume-unchanged zsh/history || true
files=(bin bashrc zsh zshrc zprofile vim vimrc tmux.conf p10k.zsh)
for x in "${files[@]}"; do
    info "install symbolic .$x"
    $LN "$(pwd -P)/$x" "$HOME/.$x"
done

# install fonts instead of create symlinks.
info "install fonts"
if [ "$(uname)" = "Darwin" ]; then
    mkdir -pv ~/Library/Fonts
    cp -fv fonts/* ~/Library/Fonts/
else
    mkdir -pv ~/.local/share/fonts
    cp -fv fonts/* ~/.local/share/fonts/
    fc-cache -fv || true
fi
#<<

#>> install programs
progs=( zsh vim git wget curl tree tmux htop )
info "install programs"
if which brew &>/dev/null; then # prefer
    PM='NONINTERACTIVE=1 brew install -q'
elif [ -f /etc/apt/sources.list ]; then
    if check http://mirrors.mtdcy.top; then
        sudo sed -e "s|archive.ubuntu.com|mirrors.mtdcy.top|g" \
                 -e "s|security.ubuntu.com|mirrors.mtdcy.top|g" \
                 -i /etc/apt/sources.list \
                 -i /etc/apt/sources.list.d/* || true
    fi
    sudo apt update
    PM='sudo apt install -y'
elif which pacman &>/dev/null; then
    if check http://mirrors.mtdcy.top; then
        sed -e "s|mirror.msys2.org|mirrors.mtdcy.top/msys2|g" \
            -i /etc/pacman.d/mirrorlist*
    fi
    pacman -Sy
    PM='pacman -Sq --noconfirm'
else
    error "Please set package manager first."
    exit 1
fi

for x in "${progs[@]}"; do
    eval -- "$PM" "$x" || true
done

# special packages
#if which brew &> /dev/null; then
if [ "$(uname)" = "Darwin" ]; then
    $PM coreutils findutils go lazygit
else
    $PM golang || true
fi

info "install nvim"
if check https://git.mtdcy.top/mtdcy/pretty.nvim; then
    bash -c "$(curl -fsSL https://git.mtdcy.top/mtdcy/pretty.nvim/raw/branch/main/install.sh)" install
else
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/mtdcy/pretty.nvim/main/install.sh)" install
fi
#<<

#>> default settings
info "apply default settings"
$SHELL --version | grep -qFw 'zsh 5' || {
    info "apply zsh shell"
    chsh -s "$(which zsh)"
}

EDITOR="$(which vim)"
if which update-alternatives && which editor; then
    sudo update-alternatives --install "$(which editor)" editor "$(readlink -f $EDITOR)" 100
    sudo update-alternatives --set editor "$(readlink -f $EDITOR)"
fi

if [ "$(uname)" = "Darwin" ]; then
    info "apply iterm2 settings"
    defaults import com.googlecode.iterm2 iterm2/com.googlecode.iterm2.plist
fi
#<<

#>> git:
info "apply git settings"
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

git config --global --get user.name     || git config --global --replace-all user.name  "$(read -r -p 'user.name: '; echo "$REPLY")"
git config --global --get user.email    || git config --global --replace-all user.email "$(read -r -p 'user.email: '; echo "$REPLY")"
#<<

# vim:ts=4:sw=4:ai:foldmethod=marker:foldlevel=0:fmr=#>>,#<<
