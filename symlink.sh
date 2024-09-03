#!/bin/bash

files="zshrc profile tmux.conf vimrc"

for file in $files; do 
	ln -sf ~/dotfiles/$file ~/.$file
#	echo $file >> test.txt
done

# ln -s ~/.dotfiles/vimrc ~/.vimrc
 
