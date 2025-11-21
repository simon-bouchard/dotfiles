#!/bin/bash

files="zshrc tmux.conf vimrc gitconfig gitignore_global"

for file in $files; do 
	ln -sf ~/dotfiles/$file ~/.$file

done

# Starship configuration
mkdir -p ~/.config
ln -sf ~/dotfiles/starship.toml ~/.config/starship.toml

mkdir -p ~/.config/nvim
ln -sf ~/dotfiles/init.lua ~/.config/nvim/init.lua

echo "Dotfiles installed"


