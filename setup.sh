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

# Install zsh plugins

# Define the Oh My Zsh custom plugin directory
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
PLUGIN_DIR="$ZSH_CUSTOM/plugins"
AUTOSUGGESTIONS_REPO="https://github.com/zsh-users/zsh-autosuggestions"
SYNTAX_HIGHLIGHTING_REPO="https://github.com/zsh-users/zsh-syntax-highlighting"
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
install_plugin "$SYNTAX_HIGHLIGHTING_REPO" "zsh-syntax-highlighting"
install_plugin "$FAST_SYNTAX_HIGHLIGHTING_REPO" "fast-syntax-highlighting"
install_plugin "$AUTOCOMPLETE_REPO" "zsh-autocomplete"

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

# Meld installation
if ! command -v meld >/dev/null 2>&1; then
    echo "Installing meld..."
    sudo apt update -y
    sudo apt install -y meld
else
    echo "Meld is already installed."
fi

# xclip installation (for clipboard operations)
if ! command -v xclip >/dev/null 2>&1; then
    echo "Installing xclip..."
    sudo apt install -y xclip
else
    echo "xclip is already installed."
fi

# ===== NEW PYTHON TOOLING =====

# Install uv (Python package manager)
if ! command -v uv >/dev/null 2>&1; then
    echo "Installing uv (Python package manager)..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
else
    echo "uv is already installed."
fi

# Ensure Python3 and pip are installed
if ! command -v python3 >/dev/null 2>&1; then
    echo "Installing Python3..."
    sudo apt install -y python3 python3-pip python3-venv
else
    echo "Python3 is already installed."
fi

# Install Python development tools via pip
echo "Installing Python development tools..."
python3 -m pip install --user --upgrade pip
python3 -m pip install --user ruff pyright pre-commit debugpy

# Install zoxide (smart cd)
if ! command -v zoxide >/dev/null 2>&1; then
    echo "Installing zoxide..."
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
else
    echo "zoxide is already installed."
fi

# Install btop (system monitor - optional)
if ! command -v btop >/dev/null 2>&1; then
    echo "Installing btop (system monitor)..."
    sudo apt install -y btop
else
    echo "btop is already installed."
fi

# Install Node.js if not present (needed for some LSP servers)
if ! command -v node >/dev/null 2>&1; then
    echo "Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt install -y nodejs
else
    echo "Node.js is already installed."
fi

echo ""
echo "===================="
echo "Machine setup complete!"
echo "===================="
echo ""
echo "Next steps:"
echo "1. Run ./symlink.sh to link dotfiles"
echo "2. Restart your shell or run: source ~/.zshrc"
echo "3. Open Neovim - plugins will auto-install via Mason"
echo "4. In your projects, run: pre-commit install"
echo ""
