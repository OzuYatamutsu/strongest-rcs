#!/bin/bash

# Get location of fish
sed "s|default-shell[[:space:]].*$|default-shell $(which fish)|g" tmux.conf > tmux_temp
mv -fv tmux_temp ~/.tmux.conf

cp -fv config.fish ~/.config/fish/
cp -fv vimrc ~/.vimrc
