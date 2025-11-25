#!/bin/bash

DOTFILES="$HOME/dotfiles"

# Shell configs
ln -sf "$DOTFILES/config/zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES/config/tmux.conf" "$HOME/.tmux.conf"

# Vim/Neovim
ln -sf "$DOTFILES/config/vimrc" "$HOME/.vimrc"
mkdir -p "$HOME/.config/nvim"
ln -sf "$DOTFILES/config/init.lua" "$HOME/.config/nvim/init.lua"

mkdir -p ~/.config
ln -sf ~/dotfiles/config/starship.toml ~/.config/starship.toml
ln -sf ~/dotfiles/config/ruff.toml ~/.config/ruff.toml

# Git
ln -sf "$DOTFILES/git/gitconfig" "$HOME/.gitconfig"
ln -sf "$DOTFILES/git/gitignore_global" "$HOME/.gitignore_global"

# Starship prompt
mkdir -p "$HOME/.config"
ln -sf "$DOTFILES/config/starship.toml" "$HOME/.config/starship.toml"

echo "✅ Dotfiles symlinked successfully"
