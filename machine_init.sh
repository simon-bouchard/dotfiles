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

	echo "Installing $plugin_name..."
	git clone "$repo_url" "$plugin_path"
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

echo "Installation complete!"

# Meld installation 

# Function to install meld on Debian-based systems (Ubuntu, etc.)
sudo apt update -y
sudo apt install -y meld

        
echo "Meld installation complete."
