#!/bin/bash
### Installation script, fish and bash
INSTALL_CWD=$PWD

# CATESHELL requires python3 and pip3 to be defined.
# Fail immediately if this check doesn't pass.
if [[ "$(which python3)" == "" ]]; then
  echo "CATESHELL requires Python >= 3.6, and 'python3' to be defined."
  echo "Please remedy this situation manually."
fi

if [[ "$(which pip3)" == "" ]]; then
  echo "CATESHELL requires Python >= 3.6, and 'pip3' to be defined."
  echo "Please remedy this situation manually."
fi

# Where will CATESHELL live?
export CATESHELL_HOME="$HOME/.config/cateshell"

# Clean this directory.
if [ -d "$CATESHELL_HOME" ]; then
    rm -Rfv "${CATESHELL_HOME}/*" || true
fi

# Install dependencies
# Python dependencies
pip3 install -r requirements.txt --user

# - Pathogen (plugin manager for vim)
mkdir -p ~/.vim/autoload ~/.vim/bundle
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

# - vim-airline (styling for vim)
if [ ! -d ~/.vim/bundle/vim-airline ]; then
  # Install
  git clone https://github.com/vim-airline/vim-airline ~/.vim/bundle/vim-airline
else
  # ...or update.
  cd ~/.vim/bundle/vim-airline && git pull
  cd $INSTALL_CWD
fi

# - vim-airline-themes (styling for vim)
if [ ! -d ~/.vim/bundle/vim-airline-themes ]; then
  # Install
  git clone https://github.com/vim-airline/vim-airline-themes ~/.vim/bundle/vim-airline-themes
else
  # ...or update.
  cd ~/.vim/bundle/vim-airline-themes && git pull
  cd $INSTALL_CWD
fi

# - bass (backwards-compatibility for fish)
git clone https://github.com/edc/bass.git 2>&1 \
  && cd bass \
  && make install 2>&1 \
  && cd .. \
  && rm -Rf bass

# Inject tmux modifications and install
sed "s|default-shell[[:space:]].*$|default-shell $(which fish)|g" tmux.conf > tmux_temp
echo "set -ga terminal-overrides ',${TERM}*:smcup@:rmcup@'" >> tmux_temp
mv -fv tmux_temp ~/.tmux.conf

# Inject screen modifications to installed screen config
grep -q -F "termcapinfo ${TERM}*|xs|rxvt|terminal ti@:te@" ~/.screenrc \
  || echo "termcapinfo ${TERM}*|xs|rxvt|terminal ti@:te@" >> ~/.screenrc

# Install vimrc
cp -fv vimrc ~/.vimrc

# Install CATESHELL core
mkdir "$CATESHELL_HOME" || true
cp -fv cateshell_prompt.py "$CATESHELL_HOME"
cp -fv cateshell_store.py "$CATESHELL_HOME"
cp -fv cateshell_git_support.py "$CATESHELL_HOME"
cp -fv cateshell_welcome_screen.py "$CATESHELL_HOME"
cp -fv cateshell_cat_header.txt "$CATESHELL_HOME"

# Install CATESHELL shell configs
sed "s|_CATESHELL_HOME|$CATESHELL_HOME|g" cateshell_fish.fish \
  > cateshell_fish.fish.temp
mv -fv cateshell_fish.fish.temp "$CATESHELL_HOME/cateshell_fish.fish"
sed "s|_CATESHELL_HOME|$CATESHELL_HOME|g" cateshell_bash.sh \
  > cateshell_bash.sh.temp
mv -fv cateshell_bash.sh.temp "$CATESHELL_HOME/cateshell_bash.sh"

# Install CATESHELL health checks and plugins
mkdir "$CATESHELL_HOME/health_checks" || true
cp -Rfv health_checks/*.py "$CATESHELL_HOME/health_checks/"
mkdir "$CATESHELL_HOME/plugins" || true
cp -Rfv plugins/*.py "$CATESHELL_HOME/plugins/"

# Install CATESHELL scripts
mkdir ~/scripts || true
mkdir "$CATESHELL_HOME/scripts" || true
cp -Rfv scripts/* "$CATESHELL_HOME/scripts/"

# Set current directory as update source
python3 "${CATESHELL_HOME}/cateshell_store.py" CATESHELL_HOME $CATESHELL_HOME
python3 "${CATESHELL_HOME}/cateshell_store.py" CATESHELL_SOURCE_DIR $PWD

# Point bash to bash CATESHELL config
grep -q -F "source ${CATESHELL_HOME}/cateshell_bash.sh" ~/.bashrc \
  || echo "source ${CATESHELL_HOME}/cateshell_bash.sh" >> ~/.bashrc

# Point fish to fish CATESHELL config
mkdir "$HOME/.config/fish" || true
touch "$HOME/.config/fish/config.fish"
grep -q -F "source ${CATESHELL_HOME}/cateshell_fish.fish" "$HOME/.config/fish/config.fish" \
  || echo "source ${CATESHELL_HOME}/cateshell_fish.fish" >> "$HOME/.config/fish/config.fish"

# Done.