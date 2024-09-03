#!/bin/bash

files="zshrc profile tmux.conf vimrc"

for file in $files; do 
	ln -sf ~/dotfiles/$file ~/.$file

done


 
