#!/bin/bash
# admin_setup.sh
# Run with sudo privileges on ws-dev-06 for user sbouchard.
# Idempotent - safe to re-run if interrupted or if some items are already done.
set -e

echo "===================="
echo "IT setup for sbouchard - ws-dev-06"
echo "===================="

# ----- Standard apt packages -----
PACKAGES="zsh tmux fzf direnv btop"

for pkg in $PACKAGES; do
    if ! command -v "$pkg" >/dev/null 2>&1; then
        echo "Installing $pkg..."
        sudo apt install -y "$pkg"
    else
        echo "$pkg already installed, skipping."
    fi
done

# ----- Neovim (needs PPA - apt's default version is too old) -----
if ! command -v nvim >/dev/null 2>&1; then
    echo "Adding neovim PPA and installing neovim..."
    sudo add-apt-repository ppa:neovim-ppa/unstable -y
    sudo apt update
    sudo apt install -y neovim
else
    echo "neovim already installed, skipping."
fi

# ----- nvtop (native Ubuntu only, not WSL) -----
if ! grep -q microsoft /proc/version 2>/dev/null; then
    if ! command -v nvtop >/dev/null 2>&1; then
        echo "Installing nvtop..."
        sudo apt install -y nvtop
    else
        echo "nvtop already installed, skipping."
    fi
else
    echo "WSL detected, skipping nvtop (native-Ubuntu only)."
fi

# ----- Shell change to zsh -----
# Requires zsh to be registered in /etc/shells first.
ZSH_PATH="$(which zsh)"
if [ -n "$ZSH_PATH" ]; then
    if ! grep -qx "$ZSH_PATH" /etc/shells; then
        echo "Registering $ZSH_PATH in /etc/shells..."
        echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
    fi

    if [ "$SHELL" != "$ZSH_PATH" ]; then
        echo "Changing sbouchard's default shell to zsh..."
        sudo chsh -s "$ZSH_PATH" sbouchard
    else
        echo "Default shell is already zsh."
    fi
else
    echo "zsh not found on PATH - shell change skipped (should not happen if the apt step above succeeded)."
fi

echo ""
echo "===================="
echo "Admin setup complete."
echo "===================="
