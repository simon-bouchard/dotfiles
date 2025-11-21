#!/bin/bash
#setup.sh

# Improved machine initialization script with error handling
# Exit on error and undefined variables
set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✅${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

log_error() {
    echo -e "${RED}❌${NC} $1"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ============================================================================
# SYSTEM UPDATES
# ============================================================================
log_info "Updating system packages..."
sudo apt update
sudo apt upgrade -y

# ============================================================================
# ZSH SHELL
# ============================================================================
log_info "Setting up Zsh..."

if ! command_exists zsh; then
    log_info "Installing Zsh..."
    sudo apt install -y zsh
    log_success "Zsh installed"
else
    log_success "Zsh already installed"
fi

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    log_info "Installing Oh My Zsh..."
    RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended
    log_success "Oh My Zsh installed"
else
    log_success "Oh My Zsh already installed"
fi

# ============================================================================
# ZSH PLUGINS
# ============================================================================
log_info "Installing Zsh plugins..."

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
PLUGIN_DIR="$ZSH_CUSTOM/plugins"
mkdir -p "$PLUGIN_DIR"

# Function to install a plugin if not already present
install_plugin() {
    local repo_url=$1
    local plugin_name=$2
    local plugin_path="$PLUGIN_DIR/$plugin_name"

    if [ -d "$plugin_path" ]; then
        log_success "$plugin_name already installed"
    else
        log_info "Installing $plugin_name..."
        git clone "$repo_url" "$plugin_path" 2>/dev/null || {
            log_error "Failed to install $plugin_name"
            return 1
        }
        log_success "$plugin_name installed"
    fi
}

# Install all plugins
install_plugin "https://github.com/zsh-users/zsh-autosuggestions" "zsh-autosuggestions"
install_plugin "https://github.com/zsh-users/zsh-syntax-highlighting" "zsh-syntax-highlighting"
install_plugin "https://github.com/zdharma-continuum/fast-syntax-highlighting" "fast-syntax-highlighting"
install_plugin "https://github.com/marlonrichert/zsh-autocomplete" "zsh-autocomplete"
install_plugin "https://github.com/Aloxaf/fzf-tab" "fzf-tab"
install_plugin "https://github.com/zsh-users/zsh-history-substring-search" "zsh-history-substring-search"
install_plugin "https://github.com/zsh-users/zsh-completions" "zsh-completions"

# ============================================================================
# TMUX
# ============================================================================
log_info "Setting up Tmux..."

if ! command_exists tmux; then
    log_info "Installing Tmux..."
    sudo apt install -y tmux
    log_success "Tmux installed"
else
    log_success "Tmux already installed"
fi

# Install TPM (Tmux Plugin Manager)
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    log_info "Installing Tmux Plugin Manager (TPM)..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    log_success "TPM installed"
else
    log_success "TPM already installed"
fi

# ============================================================================
# NEOVIM & LSP SETUP
# ============================================================================
log_info "Setting up Neovim..."

if ! command_exists nvim; then
    log_info "Installing Neovim..."
    sudo apt install -y neovim
    log_success "Neovim installed"
else
    log_success "Neovim already installed"
fi

# Create nvim config directory
mkdir -p "$HOME/.config/nvim"

# Install mason.nvim for LSP/formatter/linter management
if [ ! -d "$HOME/.local/share/nvim/lazy/mason.nvim" ]; then
    log_info "Note: mason.nvim will be auto-installed by lazy.nvim on first nvim launch"
else
    log_success "mason.nvim directory exists"
fi

# ============================================================================
# STARSHIP PROMPT
# ============================================================================
log_info "Setting up Starship prompt..."

if ! command_exists starship; then
    log_info "Installing Starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
    log_success "Starship installed"
else
    log_success "Starship already installed"
fi

# ============================================================================
# FONTS
# ============================================================================
log_info "Installing JetBrainsMono Nerd Font..."

FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR/JetBrainsMono"

if [ ! -f "$FONT_DIR/JetBrainsMono/JetBrainsMono Regular Nerd Font Complete.ttf" ]; then
    ORIG_DIR="$(pwd)"
    cd "$FONT_DIR"

    JETBRAINS_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
    JETBRAINS_ZIP="JetBrainsMono.zip"

    log_info "Downloading JetBrainsMono..."
    if ! curl -fsSL -o "$JETBRAINS_ZIP" "$JETBRAINS_URL"; then
        log_error "Failed to download JetBrainsMono font"
        cd "$ORIG_DIR"
    else
        log_info "Extracting font..."
        unzip -o "$JETBRAINS_ZIP" -d JetBrainsMono >/dev/null
        rm "$JETBRAINS_ZIP"

        log_info "Refreshing font cache..."
        fc-cache -fv >/dev/null

        cd "$ORIG_DIR"
        log_success "JetBrainsMono font installed"
    fi
else
    log_success "JetBrainsMono font already installed"
fi

# ============================================================================
# ADDITIONAL UTILITIES
# ============================================================================
log_info "Installing additional utilities..."

# LSD (pretty ls)
if ! command_exists lsd; then
    log_info "Installing lsd..."
    sudo snap install lsd
    log_success "lsd installed"
else
    log_success "lsd already installed"
fi

# Meld (merge tool)
if ! command_exists meld; then
    log_info "Installing Meld..."
    sudo apt install -y meld
    log_success "Meld installed"
else
    log_success "Meld already installed"
fi

# Git (usually pre-installed, but let's make sure)
if ! command_exists git; then
    log_info "Installing Git..."
    sudo apt install -y git
    log_success "Git installed"
else
    log_success "Git already installed"
fi

# Curl (usually pre-installed, but let's make sure)
if ! command_exists curl; then
    log_info "Installing curl..."
    sudo apt install -y curl
    log_success "curl installed"
else
    log_success "curl already installed"
fi

# FZF (fuzzy finder - useful for fzf-tab)
if ! command_exists fzf; then
    log_info "Installing fzf..."
    sudo apt install -y fzf
    log_success "fzf installed"
else
    log_success "fzf already installed"
fi

# Ripgrep (better grep - useful with fzf and telescope)
if ! command_exists rg; then
    log_info "Installing ripgrep..."
    sudo apt install -y ripgrep
    log_success "ripgrep installed"
else
    log_success "ripgrep already installed"
fi

# ============================================================================
# CHANGE DEFAULT SHELL
# ============================================================================
log_info "Configuring default shell..."

if [ "$SHELL" != "$(which zsh)" ]; then
    log_info "Changing default shell to Zsh..."
    chsh -s "$(which zsh)"
    log_success "Default shell changed to Zsh (will take effect on next login)"
else
    log_success "Default shell is already Zsh"
fi

# ============================================================================
# COMPLETION
# ============================================================================
echo ""
log_success "Machine initialization complete!"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Run: source ~/dotfiles/load_dotfiles.sh"
echo "2. Close and reopen your terminal to load Zsh"
echo "3. Open Neovim and let it install plugins: nvim"
echo "4. Inside Neovim, run: :MasonInstall python-lsp-server"
echo "   (or whatever language servers you need)"
echo ""
