#!/bin/bash -e

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

if [ -z "$1" ] || [ "$1" = "install" ]; then
    if [ -d "$(dirname "$0")/.git" ]; then
        cd "$(dirname "$0")" || exit
        git pull --rebase --force
    else
        git clone --depth=1 https://git.mtdcy.top/mtdcy/dotfiles.git "$HOME/.files"
        cd "$HOME/.files" || exit
    fi

    info "install cmdlets.sh"
    mkdir -pv bin
    if check https://git.mtdcy.top/mtdcy/cmdlets; then
        curl -o bin/cmdlets.sh -sL https://git.mtdcy.top/mtdcy/cmdlets/raw/branch/main/cmdlets.sh
    else
        curl -o bin/cmdlets.sh -sL https://raw.githubusercontent.com/mtdcy/cmdlets/main/cmdlets.sh
    fi
    chmod a+x bin/cmdlets.sh

    utils=(sed grep awk ln)
    for x in "${utils[@]}"; do
        bash bin/cmdlets.sh install "$x"
    done
    #<< its safe to use gnu tools from now on ##

    exec ./install.sh --no-update
fi

# always copy in msys2
[[ "$OSTYPE" =~ msys ]] && LN='cp -rfv' || LN='./bin/ln -svfT'

#>> install dotfiles

# copy files
files=(gitconfig)
for x in "${files[@]}"; do
    info "install .$x"
    cp -fv "$x" "$HOME/.$x"
done

# 'fatal: Unable to mark file zsh/history'
git update-index --assume-unchanged zsh/history || true
files=(bin bashrc profile zsh zshrc zprofile vim vimrc tmux.conf p10k.zsh)
for x in "${files[@]}"; do
    info "install symbolic .$x"
    $LN "$(pwd -P)/$x" "$HOME/.$x"
done

# install fonts instead of create symlinks.
info "install fonts"
if [ "$(uname)" = "Darwin" ]; then
    mkdir -pv ~/Library/Fonts
    find fonts -name "*.ttf" -exec cp -fv {} ~/Library/Fonts/ \;
    find fonts -name "*.otf" -exec cp -fv {} ~/Library/Fonts/ \;
else
    mkdir -pv ~/.local/share/fonts
    cp -rfv fonts/* ~/.local/share/fonts/
    fc-cache -fv || true
fi
#<<

#>> git:
git config --global --replace-all user.name  "$(read -r -p 'git user.name: '; echo "$REPLY")"
git config --global --replace-all user.email "$(read -r -p 'git user.email: '; echo "$REPLY")"
#<<

#>> install programs
info "install programs"
if which brew &>/dev/null; then # prefer
    NONINTERACTIVE=1 brew install -q \
        zsh vim git wget curl tree tmux htop \
        python3 npm
    if [ "$(uname)" = "Darwin" ]; then
        NONINTERACTIVE=1 brew install -q \
            coreutils findutils go lazygit
    fi
elif [ -f /etc/apt/sources.list ]; then
    if check http://mirrors.mtdcy.top; then
        sudo sed -e "s|archive.ubuntu.com|mirrors.mtdcy.top|g" \
                 -e "s|security.ubuntu.com|mirrors.mtdcy.top|g" \
                 -i /etc/apt/sources.list \
                 -i /etc/apt/sources.list.d/* || true
    fi
    sudo apt update
    sudo apt install -y \
        zsh vim git wget curl tree tmux htop  \
        python3 python3-venv npm golang \
        fontconfig
elif which pacman &>/dev/null; then
    if check http://mirrors.mtdcy.top; then
        sed -e "s|mirror.msys2.org|mirrors.mtdcy.top/msys2|g" \
            -i /etc/pacman.d/mirrorlist*
    fi
    pacman -Sy
    pacman -Sq --noconfirm \
        zsh vim git wget curl tree tmux htop  \
        python3 npm go
else
    error "Please set package manager first."
    exit 1
fi

info "install nvim"
if check https://git.mtdcy.top/mtdcy/pretty.nvim; then
    bash -c "$(curl -fsSL https://git.mtdcy.top/mtdcy/pretty.nvim/raw/branch/main/install.sh)"
else
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/mtdcy/pretty.nvim/main/install.sh)"
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

# vim:ts=4:sw=4:ai:foldmethod=marker:foldlevel=0:fmr=#>>,#<<
