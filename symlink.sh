#!/bin/bash

# Shell config files (from config/)
shell_files="zshrc zshenv tmux.conf vimrc"

for file in $shell_files; do
	ln -sf ~/dotfiles/config/$file ~/.$file
done

# Git files (from git/)
git_files="gitconfig gitignore_global"

for file in $git_files; do
	ln -sf ~/dotfiles/git/$file ~/.$file
done

# Machine-local git identity (not tracked - copied once, then yours to edit)
if [ ! -f ~/.gitconfig.local ]; then
	cp ~/dotfiles/templates/gitconfig.local.example ~/.gitconfig.local
	echo "Created ~/.gitconfig.local - edit it with your name/email before committing"
fi

# Machine-local zsh settings (not tracked - copied once, then yours to edit)
if [ ! -f ~/.zshrc.local ]; then
	cp ~/dotfiles/templates/zshrc.local.example ~/.zshrc.local
	echo "Created ~/.zshrc.local - add this machine's PATH, secrets and overrides"
fi

# Starship config (ASCII variant for machines without a Nerd Font, see ~/.zshrc.local)
mkdir -p ~/.config
ln -sf ~/dotfiles/config/starship.toml ~/.config/starship.toml
ln -sf ~/dotfiles/config/starship-ascii.toml ~/.config/starship-ascii.toml

# Glow style (dark theme without margins, so copied text has no leading spaces)
mkdir -p ~/.config/glow
ln -sf ~/dotfiles/config/glow-no-margin.json ~/.config/glow/no-margin.json

# Ruff config
mkdir -p ~/.config/ruff
ln -sf ~/dotfiles/config/ruff.toml ~/.config/ruff/ruff.toml

# Atuin shell history config
mkdir -p ~/.config/atuin
ln -sf ~/dotfiles/config/atuin.toml ~/.config/atuin/config.toml

# Neovim config
mkdir -p ~/.config/nvim
ln -sf ~/dotfiles/config/init.lua ~/.config/nvim/init.lua

# Machine-local Neovim options (not tracked - copied once, then yours to edit)
if [ ! -f ~/.config/nvim/local.lua ]; then
	cp ~/dotfiles/templates/nvim-local.example.lua ~/.config/nvim/local.lua
	echo "Created ~/.config/nvim/local.lua - set nerd_font = false if the terminal lacks one"
fi

# Claude global config and commands
mkdir -p ~/.claude
ln -sf ~/dotfiles/claude/CLAUDE.md ~/.claude/CLAUDE.md

mkdir -p ~/.claude
ln -sfn ~/dotfiles/claude/commands ~/.claude/commands

# Machine-local Claude context (not tracked - copied once, then yours to edit)
if [ ! -f ~/.claude/CLAUDE.local.md ]; then
	cp ~/dotfiles/templates/CLAUDE.local.example.md ~/.claude/CLAUDE.local.md
	echo "Created ~/.claude/CLAUDE.local.md - edit it with this machine's OS before use"
fi

# Alacritty config (native Ubuntu only)
if ! grep -q microsoft /proc/version 2>/dev/null; then
    mkdir -p ~/.config/alacritty
    ln -sf ~/dotfiles/config/alacritty.toml ~/.config/alacritty/alacritty.toml
fi

echo "Dotfiles installed"
