#!/bin/bash

# Get location of fish
sed "s|default-shell[[:space:]].*$|default-shell $(which fish)|g" tmux.conf > tmux_temp
mv -fv tmux_temp ~/.tmux.conf

# Install Pathogen (plugin manager)
mkdir -p ~/.vim/autoload ~/.vim/bundle
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

# Download vim-airline
git clone https://github.com/vim-airline/vim-airline ~/.vim/bundle/vim-airline

cp -fv config.fish ~/.config/fish/
cp -fv vimrc ~/.vimrc
