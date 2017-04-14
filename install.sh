#!/bin/bash

# Get location of fish
sed "s|default-shell[[:space:]].*$|default-shell $(which fish)|g" tmux.conf > tmux_temp
mv -fv tmux_temp ~/.tmux.conf

# Install Pathogen (plugin manager)
mkdir -p ~/.vim/autoload ~/.vim/bundle
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

# Download vim-airline
if [ ! -d ~/.vim/bundle/vim-airline ]; then
  git clone https://github.com/vim-airline/vim-airline ~/.vim/bundle/vim-airline
else
  echo "vim-airline looks like it exists already; not cloning."
fi

# Download vim-airline-themes
if [ ! -d ~/.vim/bundle/vim-airline-themes ]; then
  git clone https://github.com/vim-airline/vim-airline-themes ~/.vim/bundle/vim-airline-themes
else
  echo "vim-airline-themes looks like it exists already; not cloning."
fi

# Download bass (backwards-compatibility for fish)
git clone https://github.com/edc/bass.git
cd bass
make install
cd ..
rm -Rf bass

cp -fv config.fish ~/.config/fish/
cp -fv vimrc ~/.vimrc
