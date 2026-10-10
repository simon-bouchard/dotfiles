#!/bin/bash

#Install Zsh and oh-my-zsh

#Zsh
if ! command -v zsh >/dev/null 2>&1; then
    echo "Zsh not found. Installing Zsh..."
    sudo apt update && sudo apt install -y zsh
else
    echo "Zsh is already installed."
fi

#Oh-my-Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    # Run the Oh My Zsh installation script
    RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended
else
    echo "Oh My Zsh is already installed."
fi

#Install Tmux
if ! command -v tmux &> /dev/null
then
	echo 'Installing tmux...'
	sudo apt-get install -y tmux
else
	echo 'Tmux is already installed.'
fi

# Install TPM (tmux plugin manager); tmux.conf loads it, then prefix + I installs the plugins
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "Installing TPM..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
else
    echo "TPM is already installed."
fi

# Install zsh plugins

# Define the Oh My Zsh custom plugin directory
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
PLUGIN_DIR="$ZSH_CUSTOM/plugins"
AUTOSUGGESTIONS_REPO="https://github.com/zsh-users/zsh-autosuggestions"
FAST_SYNTAX_HIGHLIGHTING_REPO="https://github.com/zdharma-continuum/fast-syntax-highlighting"
AUTOCOMPLETE_REPO="https://github.com/marlonrichert/zsh-autocomplete"

# Create custom plugins directory if it doesn't exist
mkdir -p "$PLUGIN_DIR"

# Function to install a plugin
install_plugin() {
	local repo_url=$1
	local plugin_name=$2
	local plugin_path="$PLUGIN_DIR/$plugin_name"

	if [ -d "$plugin_path" ]; then
		echo "$plugin_name already installed."
	else
		echo "Installing $plugin_name..."
		git clone "$repo_url" "$plugin_path"
	fi
}

# Install each plugin
install_plugin "$AUTOSUGGESTIONS_REPO" "zsh-autosuggestions"
install_plugin "$FAST_SYNTAX_HIGHLIGHTING_REPO" "fast-syntax-highlighting"
install_plugin "$AUTOCOMPLETE_REPO" "zsh-autocomplete"
install_plugin "https://github.com/zsh-users/zsh-completions" "zsh-completions"

echo "Zsh, Oh My Zsh, and Zsh plugins installed!"

# Switch shell to zsh
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "Changing default shell to Zsh..."
    chsh -s $(which zsh)
else
    echo "Default shell is already Zsh."
fi


if ! command -v starship >/dev/null 2>&1; then
    echo "Starship not found. Installing Starship prompt..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
else
    echo "Starship is already installed."
fi

# CLI dependencies: Telescope (ripgrep, fd-find), Treesitter and fzf-native (build-essential),
# Mason and the font install below (unzip), nvim-lint (shellcheck)
for pkg in ripgrep fd-find build-essential unzip shellcheck; do
    if dpkg -s "$pkg" >/dev/null 2>&1; then
        echo "$pkg is already installed."
    else
        echo "Installing $pkg..."
        sudo apt install -y "$pkg"
    fi
done

# Install JetBrainsMono Nerd Font
ORIG_DIR="$(pwd)"
FONT_DIR="$HOME/.local/share/fonts"
JETBRAINS_ZIP="JetBrainsMono.zip"
JETBRAINS_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"

if fc-list | grep -qi "JetBrainsMono"; then
    echo "JetBrainsMono Nerd Font already installed."
else
    echo "Installing JetBrainsMono Nerd Font..."
    mkdir -p "$FONT_DIR/JetBrainsMono"
    cd "$FONT_DIR"

    # Download font zip if missing
    if [ ! -f "$JETBRAINS_ZIP" ]; then
        curl -fsSL -o "$JETBRAINS_ZIP" "$JETBRAINS_URL"
    fi

    # Extract (quietly, overwrite OK)
    unzip -o "$JETBRAINS_ZIP" -d JetBrainsMono >/dev/null
    rm -f "$JETBRAINS_ZIP"

    # Refresh font cache
    fc-cache -fv >/dev/null

    # Return to original directory
    cd "$ORIG_DIR"

    echo "JetBrainsMono Nerd Font installed."
fi

# Install Lsd (pretty ls)
if ! command -v lsd >/dev/null 2>&1; then
    echo "Installing lsd..."
    sudo snap install lsd
else
    echo "lsd is already installed."
fi

# xclip installation (for clipboard operations)
if ! command -v xclip >/dev/null 2>&1; then
    echo "Installing xclip..."
    sudo apt install -y xclip
else
    echo "xclip is already installed."
fi

# Install fzf
if ! command -v fzf >/dev/null 2>&1; then
    echo "Installing fzf..."
    sudo apt install -y fzf
else
    echo "fzf is already installed."
fi

# Install direnv
if ! command -v direnv >/dev/null 2>&1; then
    echo "Installing direnv..."
    sudo apt install -y direnv
else
    echo "direnv is already installed."
fi

# Install Neovim (via PPA for current version — apt default is too old)
if ! command -v nvim >/dev/null 2>&1; then
    echo "Installing Neovim..."
    sudo add-apt-repository ppa:neovim-ppa/unstable -y
    sudo apt update
    sudo apt install -y neovim
else
    echo "Neovim is already installed."
fi

# tree-sitter CLI: nvim-treesitter's main branch (used on nvim 0.12+) builds parsers with it.
# Prebuilt release binary; apt doesn't package it and the docs advise against the npm one.
if ! command -v tree-sitter >/dev/null 2>&1; then
    case "$(uname -m)" in
        x86_64) TS_ARCH=x64 ;;
        aarch64) TS_ARCH=arm64 ;;
        *) TS_ARCH="" ;;
    esac
    if [ -n "$TS_ARCH" ]; then
        echo "Installing tree-sitter CLI..."
        mkdir -p "$HOME/.local/bin"
        curl -fsSL "https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-$TS_ARCH.gz" \
            | gunzip > "$HOME/.local/bin/tree-sitter"
        chmod +x "$HOME/.local/bin/tree-sitter"
    else
        echo "No prebuilt tree-sitter CLI for $(uname -m); install it manually."
    fi
else
    echo "tree-sitter CLI is already installed."
fi

# ===== PYTHON TOOLING =====

# Install uv (Python package manager)
if ! command -v uv >/dev/null 2>&1; then
    echo "Installing uv (Python package manager)..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
else
    echo "uv is already installed."
fi

# Ensure Python3 is installed
if ! command -v python3 >/dev/null 2>&1; then
    echo "Installing Python3..."
    sudo apt install -y python3 python3-venv
else
    echo "Python3 is already installed."
fi

# Install Python dev tools as isolated uv tools (pip --user is blocked on newer Ubuntu)
export PATH="$HOME/.local/bin:$PATH"
for tool in ruff pyright pre-commit debugpy; do
    if uv tool list 2>/dev/null | grep -q "^$tool "; then
        echo "$tool is already installed."
    else
        echo "Installing $tool..."
        uv tool install "$tool"
    fi
done

# Install zoxide (smart cd)
if ! command -v zoxide >/dev/null 2>&1; then
    echo "Installing zoxide..."
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
else
    echo "zoxide is already installed."
fi

# Install Atuin (shell history list on Up/Ctrl-R). Uses the release installer directly: the
# setup.atuin.sh wrapper edits ~/.zshrc and ~/.bashrc and installs AI agent hooks.
if ! command -v atuin >/dev/null 2>&1; then
    echo "Installing Atuin..."
    curl --proto '=https' --tlsv1.2 -LsSf \
        https://github.com/atuinsh/atuin/releases/latest/download/atuin-installer.sh \
        | ATUIN_INSTALL_DIR="$HOME/.local/bin" ATUIN_NO_MODIFY_PATH=1 sh
    if [ -f "$HOME/.zsh_history" ]; then
        echo "Importing zsh history into Atuin..."
        HISTFILE="$HOME/.zsh_history" "$HOME/.local/bin/atuin" import zsh
    fi
else
    echo "Atuin is already installed."
fi

# Install btop (system monitor - optional)
if ! command -v btop >/dev/null 2>&1; then
    echo "Installing btop (system monitor)..."
    sudo apt install -y btop
else
    echo "btop is already installed."
fi

# Install glow (terminal markdown viewer, from Charm's apt repo)
if ! command -v glow >/dev/null 2>&1; then
    echo "Installing glow..."
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
    echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" \
        | sudo tee /etc/apt/sources.list.d/charm.list >/dev/null
    sudo apt update
    sudo apt install -y glow
else
    echo "glow is already installed."
fi

# Install nvm and the LTS Node.js (needed for some LSP servers). PROFILE=/dev/null stops the
# installer from editing ~/.zshrc, which already loads nvm.
export NVM_DIR="$HOME/.nvm"
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    echo "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | PROFILE=/dev/null bash
else
    echo "nvm is already installed."
fi

. "$NVM_DIR/nvm.sh"
if ! nvm ls --no-colors 2>/dev/null | grep -q "v[0-9]"; then
    echo "Installing Node.js LTS..."
    nvm install --lts
else
    echo "Node.js is already installed."
fi

# ===== NATIVE UBUNTU ONLY =====
if ! grep -q microsoft /proc/version 2>/dev/null; then

    # Alacritty
    if ! command -v alacritty >/dev/null 2>&1; then
        echo "Installing Alacritty..."
        sudo add-apt-repository -y ppa:aslatter/ppa
        sudo apt update
        sudo apt install -y alacritty
    else
        echo "Alacritty is already installed."
    fi

    # Caps Lock → Escape remap
    echo "Remapping Caps Lock to Escape..."
    gsettings set org.gnome.desktop.input-sources xkb-options "['caps:escape']"

    # GNOME Terminal: Ctrl+Tab / Ctrl+Shift+Tab to switch tabs
    echo "Setting GNOME Terminal tab switching keys..."
    TERM_KEYS="org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/"
    gsettings set "$TERM_KEYS" next-tab '<Primary>Tab'
    gsettings set "$TERM_KEYS" prev-tab '<Primary><Shift>Tab'

    # nvtop (GPU monitor)
    if ! command -v nvtop >/dev/null 2>&1; then
        echo "Installing nvtop..."
        sudo apt install -y nvtop
    else
        echo "nvtop is already installed."
    fi

    # Timeshift (system snapshots)
    if ! command -v timeshift >/dev/null 2>&1; then
        echo "Installing Timeshift..."
        sudo apt install -y timeshift
    else
        echo "Timeshift is already installed."
    fi

fi

echo ""
echo "===================="
echo "Machine setup complete!"
echo "===================="
echo ""
echo "Next steps:"
echo "1. Run ./symlink.sh to link dotfiles"
echo "2. Restart your shell or run: source ~/.zshrc"
echo "3. Open Neovim - lazy.nvim will bootstrap itself, then plugins auto-install"
echo "4. In your projects, run: pre-commit install"
echo ""
