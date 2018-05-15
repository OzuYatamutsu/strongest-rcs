#!/bin/bash

# Get location of fish
sed "s|default-shell[[:space:]].*$|default-shell $(which fish)|g" tmux.conf > tmux_temp
mv -fv tmux_temp ~/.tmux.conf

# Inject tmux,screen graphical terminal native scrolling
echo "set -ga terminal-overrides ',${TERM}*:smcup@:rmcup@'" >> ~/.tmux.conf
echo "termcapinfo ${TERM}*|xs|rxvt|terminal ti@:te@" >> ~/.screenrc

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
git clone https://github.com/edc/bass.git && cd bass && make install && cd .. && rm -Rf bass

# Set source directory
sed "s|INSTALL_SOURCE_DIR|$(echo $PWD)|g" config.fish > config.fish.temp

# Install fishrc + plugin and health checks
mv -fv config.fish.temp ~/.config/fish/config.fish
mkdir ~/.config/fish/plugins || true
mkdir ~/.config/fish/health_checks || true
cp -Rfv plugins/*.py ~/.config/fish/plugins/
cp -Rfv health_checks/*.py ~/.config/fish/health_checks/
cp -fv cat_header ~/.config/fish/
cp -fv vimrc ~/.vimrc

# Set current directory as update directory
echo $PWD > ~/.config/fish/.update_dir

