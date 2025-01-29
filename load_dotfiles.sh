#!/bin/bash

files="zshrc tmux.conf vimrc gitconfig gitignore_global"

for file in $files; do 
	ln -sf ~/dotfiles/$file ~/.$file

done

echo "Dotfiles installed"


