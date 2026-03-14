#!/bin/bash -e

# ============================================================================
# Dotfiles Install Script - Enhanced Version
# Author: Chen Fang <mtdcy.chen@gmail.com>
# Repository: https://git.mtdcy.top/mtdcy/dotfiles.git
# ============================================================================

# Configuration
LANG=en_US.UTF-8
export PATH="$HOME/.bin:$PATH"

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Logging functions
banner() {
    echo -e "\n${BOLD}${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${CYAN}  $1${NC}"
    echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════${NC}\n"
}

prompt()    { echo -e "\n${BOLD}🛠️${NC} ${BOLD}$1${NC}" ; }
success()   { echo -e "${GREEN}✅${NC} $1"              ; }
info()      { echo -e "${BLUE}🟢${NC} $1"               ; }
warning()   { echo -e "${YELLOW}🟡${NC} $1"             ; }
error()     { echo -e "${RED}❌${NC} $1"                ; }

# ============================================================================
# Main Script
# ============================================================================

pushd "$(dirname "$0")" > /dev/null

mkdir -pv "$HOME/.bin" > /dev/null

# Check URL availability
check_url() {
    case "$1" in
        http://*|https://*)
            curl --fail -sIL --connect-timeout 1 -o /dev/null "$1" 2>/dev/null
            ;;
    esac
}

# ============================================================================
# Install cmdlets.sh
# ============================================================================

if [ -z "$1" ] || [ "$1" = "install" ]; then
    banner "📦 Initialize Repository"
    
    if [ -d .git ]; then
        info "Updating existing repository..."
        git pull --rebase --force > /dev/null 2>&1 && success "Repository updated" || warning "Update skipped"
    else
        info "Cloning dotfiles repository..."
        git clone --depth=1 https://git.mtdcy.top/mtdcy/dotfiles.git "$HOME/.files" && \
            success "Repository cloned to $HOME/.files" || \
            { error "Failed to clone repository"; exit 1; }
        cd "$HOME/.files" || exit 1
    fi

    prompt "Installing cmdlets.sh"
    
    # Fixed: Use HTTPS instead of HTTP
    if check_url https://git.mtdcy.top/mtdcy/cmdlets; then
        info "Using primary mirror (git.mtdcy.top)..."
        bash -c "$(curl -fsSL https://git.mtdcy.top/mtdcy/cmdlets/raw/branch/main/cmdlets.sh)" install && \
            success "cmdlets.sh installed from primary mirror" || \
            warning "Primary mirror failed, trying fallback..."
    else
        info "Using fallback mirror (GitHub)..."
        bash -c "$(curl -fsSL https://raw.githubusercontent.com/mtdcy/cmdlets/main/cmdlets.sh)" install && \
            success "cmdlets.sh installed from fallback mirror" || \
            { error "Both mirrors failed"; exit 1; }
    fi

    info "Installing GNU core utilities..."
    cmdlets.sh install coreutils gsed gawk grep && success "GNU tools installed" || warning "GNU tools installation skipped"
    
    success "Phase 1 completed successfully"
    
    # Continue with extra installation
    ./install.sh --no-update --extra
    exit 0
fi

# ============================================================================
# Install Dotfiles
# ============================================================================

banner "🏠 Install Dotfiles"

# Set link command based on OS
if [[ "$OSTYPE" =~ msys ]]; then
    LN='cp -rfv'
    info "Detected MSYS2, using copy instead of symlink"
else
    LN='ln -srfn'
fi

# Ignore zsh/history in git
prompt "Configuring git..."
git update-index --assume-unchanged zsh/history > /dev/null 2>&1 && success "Git configured" || info "Git config skipped"

# Install symbolic links for dotfiles
prompt "Creating symbolic links..."
files=(bashrc profile zsh zshrc zprofile vim vimrc tmux.conf p10k.zsh)
for x in "${files[@]}"; do
    if [ -e "$x" ]; then
        $LN "$(pwd -P)/$x" "$HOME/.$x" 2>/dev/null && \
            success "Linked .$x" || \
            warning "Failed to link .$x (may already exist)"
    else
        warning "File .$x not found, skipping"
    fi
done

# Install example configs (Fixed: exampls -> examples)
prompt "Installing example configurations..."
examples=( gitconfig )
for x in "${examples[@]}"; do
    if [ -f "$HOME/.$x" ]; then
        info ".$x already exists, skipping"
    else
        if [ -f "examples/$x" ]; then
            cp "examples/$x" "$HOME/.$x" && \
                success "Installed .$x" || \
                warning "Failed to install .$x"
        else
            warning "examples/$x not found"
        fi
    fi
done

# Fix zsh completion permissions
prompt "Fixing permissions..."
if [ -d zsh/completions ]; then
    chmod 0755 zsh/completions && success "Completion permissions fixed" || warning "Permission fix failed"
else
    warning "zsh/completions directory not found"
fi

# Link tools
prompt "Linking tools..."
mkdir -p "$HOME/.bin"
if [ -d tools ]; then
    for x in tools/*; do
        if [ -e "$x" ]; then
            $LN "$(pwd -P)/$x" "$HOME/.bin/$(basename "$x")" 2>/dev/null && \
                success "Linked $(basename "$x")" || \
                warning "Failed to link $(basename "$x")"
        fi
    done
    success "Tools linked"
else
    warning "tools directory not found"
fi

# ============================================================================
# Install Fonts
# ============================================================================

banner "🔤 Install Fonts"

if [ -d fonts ]; then
    if [ "$(uname)" = "Darwin" ]; then
        info "Detected macOS..."
        mkdir -pv ~/Library/Fonts > /dev/null
        find fonts -name "*.ttf" -exec cp -fv {} ~/Library/Fonts/ \; 2>/dev/null | while read -r line; do success "$line"; done
        find fonts -name "*.otf" -exec cp -fv {} ~/Library/Fonts/ \; 2>/dev/null | while read -r line; do success "$line"; done
        success "Fonts installed for macOS"
    else
        info "Detected Linux..."
        mkdir -pv ~/.local/share/fonts > /dev/null
        cp -rfv fonts/* ~/.local/share/fonts/ 2>/dev/null && \
            success "Fonts copied" || \
            warning "Font copy failed"
        fc-cache -fv > /dev/null 2>&1 && success "Font cache updated" || warning "Font cache update failed"
    fi
else
    warning "fonts directory not found, skipping"
fi

# ============================================================================
# Install Programs
# ============================================================================

banner "📦 Install Programs"

if [ -f /etc/apt/sources.list ]; then
    info "Detected APT (Debian/Ubuntu)..."
    _apt=(
        zsh vim git wget curl tree tmux htop
        python3 python3-venv npm golang
        fontconfig
    )
    sudo apt update -qq > /dev/null 2>&1 && success "APT updated" || warning "APT update failed"
    sudo apt install -y "${_apt[@]}" > /dev/null 2>&1 && \
        success "Packages installed via APT" || \
        warning "Some packages may have failed to install"
    unset _apt
    
elif which brew &>/dev/null; then
    info "Detected Homebrew (macOS)..."
    _formulae=(
        zsh vim git wget curl
        tree tmux htop
        python3 npm go
    )
    NONINTERACTIVE=1 brew install -q "${_formulae[@]}" 2>/dev/null && \
        success "Packages installed via Homebrew" || \
        warning "Some packages may have failed to install"
    unset _formulae
    
elif which pacman &>/dev/null; then
    info "Detected Pacman (Arch Linux)..."
    _pac=( zsh vim git wget curl tree tmux htop python3 npm go )
    pacman -Sy -q > /dev/null 2>&1 && success "Pacman updated" || warning "Pacman update failed"
    pacman -Sq --noconfirm "${_pac[@]}" > /dev/null 2>&1 && \
        success "Packages installed via Pacman" || \
        warning "Some packages may have failed to install"
    unset _pac
    
else
    error "No supported package manager detected."
    info "Please install packages manually or configure your package manager."
fi

# ============================================================================
# Apply Default Settings
# ============================================================================

banner "⚙️  Apply Default Settings"

# Configure default shell
if $SHELL --version 2>/dev/null | grep -qFw 'zsh 5'; then
    info "Zsh 5+ detected, skipping shell change"
else
    info "Configuring zsh as default shell..."
    if command -v chsh > /dev/null 2>&1; then
        chsh -s "$(which zsh)" 2>/dev/null && \
            success "Default shell changed to zsh" || \
            warning "Failed to change shell (may require manual intervention)"
    else
        warning "chsh not available, please set shell manually"
    fi
fi

# Configure default editor
EDITOR="$(which vim)"
if which update-alternatives > /dev/null 2>&1 && which editor > /dev/null 2>&1; then
    info "Configuring default editor (vim)..."
    sudo update-alternatives --install "$(which editor)" editor "$(readlink -f "$EDITOR")" 100 > /dev/null 2>&1 && \
        success "Editor alternative configured" || \
        warning "Failed to configure editor alternative"
    sudo update-alternatives --set editor "$(readlink -f "$EDITOR")" > /dev/null 2>&1 && \
        success "Default editor set to vim" || \
        warning "Failed to set default editor"
fi

# macOS specific settings
if [ "$(uname)" = "Darwin" ]; then
    prompt "macOS specific configuration..."
    if [ -f iterm2/com.googlecode.iterm2.plist ]; then
        info "Importing iTerm2 settings..."
        defaults import com.googlecode.iterm2 iterm2/com.googlecode.iterm2.plist 2>/dev/null && \
            success "iTerm2 settings imported" || \
            warning "Failed to import iTerm2 settings"
    else
        warning "iTerm2 plist not found"
    fi
fi

# ============================================================================
# Extra Installation (Optional)
# ============================================================================

if [[ "$*" =~ "--extra" ]]; then
    banner "🚀 Extra Installation"
    
    prompt "Installing Neovim (pretty.nvim)..."
    if check_url https://git.mtdcy.top/mtdcy/pretty.nvim; then
        info "Using primary mirror..."
        bash -c "$(curl -fsSL https://git.mtdcy.top/mtdcy/pretty.nvim/raw/branch/main/install.sh)" && \
            success "Neovim installed from primary mirror" || \
            warning "Primary mirror failed"
    else
        info "Using fallback mirror..."
        bash -c "$(curl -fsSL https://raw.githubusercontent.com/mtdcy/pretty.nvim/main/install.sh)" && \
            success "Neovim installed from fallback mirror" || \
            warning "Fallback mirror failed"
    fi
    
    # Configure neovim as default editor
    if which update-alternatives > /dev/null 2>&1 && which nvim > /dev/null 2>&1; then
        info "Configuring neovim as default editor..."
        sudo update-alternatives --install "$(which editor)" editor "$(which nvim)" 100 > /dev/null 2>&1 && \
            success "Neovim alternative configured" || \
            warning "Failed to configure neovim alternative"
        sudo update-alternatives --set editor "$(which nvim)" > /dev/null 2>&1 && \
            success "Default editor set to neovim" || \
            warning "Failed to set default editor to neovim"
    fi
    
    success "Extra installation completed"
fi

# ============================================================================
# Completion
# ============================================================================

banner "✨ Installation Complete"

echo -e "${GREEN}All phases completed successfully!${NC}\n"
echo -e "  Restart your terminal or run: ${BOLD}exec zsh${NC}"

popd > /dev/null

exit 0

# vim:ts=4:sw=4:ai:foldmethod=marker:foldlevel=0:fmr=#>>,#<<
