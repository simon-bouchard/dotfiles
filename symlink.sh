#!/bin/bash

# Shell config files (from config/)
shell_files="zshrc tmux.conf vimrc"

for file in $shell_files; do
	ln -sf ~/dotfiles/config/$file ~/.$file
done

# Git files (from git/)
git_files="gitconfig gitignore_global"

for file in $git_files; do
	ln -sf ~/dotfiles/git/$file ~/.$file
done

# Starship config
mkdir -p ~/.config
ln -sf ~/dotfiles/config/starship.toml ~/.config/starship.toml

# Ruff config
mkdir -p ~/.config/ruff
ln -sf ~/dotfiles/config/ruff.toml ~/.config/ruff/ruff.toml

# Neovim config
mkdir -p ~/.config/nvim
ln -sf ~/dotfiles/config/init.lua ~/.config/nvim/init.lua

# Claude global config and commands
mkdir -p ~/.claude
ln -sf ~/dotfiles/claude/CLAUDE.md ~/.claude/CLAUDE.md

mkdir -p ~/.claude
ln -sf ~/dotfiles/claude/commands ~/.claude/commands

# Alacritty config (native Ubuntu only)
if ! grep -q microsoft /proc/version 2>/dev/null; then
    mkdir -p ~/.config/alacritty
    ln -sf ~/dotfiles/config/alacritty.toml ~/.config/alacritty/alacritty.toml
fi

echo "Dotfiles installed"
