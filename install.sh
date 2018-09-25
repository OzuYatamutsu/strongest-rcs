#!/bin/bash
export CATELAB_METADATA_DIR="$HOME/.config/fish"

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
git clone https://github.com/edc/bass.git 2>&1 && cd bass && make install 2>&1 && cd .. && rm -Rf bass

# Clear old source files in directory
if [ -d ~/.config/fish ]; then
    rm -Rf ~/.config/fish/* || true
fi

# Install fishrc + plugin and health checks
pip3 install -r requirements.txt --user
cp -fv config.fish ~/.config/fish/config.fish
mkdir ~/.config/fish/plugins || true
mkdir ~/.config/fish/health_checks || true
cp -Rfv plugins/*.py ~/.config/fish/plugins/
cp -Rfv health_checks/*.py ~/.config/fish/health_checks/
cp -fv cat_header ~/.config/fish/
cp -fv vimrc ~/.vimrc
cp -fv welcome_screen.py ~/.config/fish/
cp -fv catelab_store.py ~/.config/fish/
cp -fv git_support.py ~/.config/fish/

# Set current directory as update directory
python3 "${CATELAB_METADATA_DIR}/catelab_store.py" CATELAB_METADATA_DIR $CATELAB_METADATA_DIR
python3 "${CATELAB_METADATA_DIR}/catelab_store.py" CATELAB_SOURCE_DIR $PWD

# Install scripts
mkdir ~/scripts || true
cp -Rfv scripts/* ~/scripts/

## BASH INSTALLATION
# Append welcome screen
grep -q -F 'if shopt -q login_shell; then' ~/.bashrc || echo 'if shopt -q login_shell; then' >> ~/.bashrc
grep -q -F '  python3 ~/.config/fish/welcome_screen.py ~/.config/fish' ~/.bashrc || echo -e '  python3 ~/.config/fish/welcome_screen.py ~/.config/fish\nfi' >> ~/.bashrc

# Append colorization
grep -q -F "PS1='\e[35m\u@\h \e[32m\w\e[39m> '" ~/.bashrc || echo "PS1='\e[35m\u@\h \e[32m\w\e[39m> '" >> ~/.bashrc

# Set default locale
grep -q -F "export LC_ALL='en_US.utf8'" ~/.bashrc || echo "export LC_ALL='en_US.utf8'" >> ~/.bashrc

