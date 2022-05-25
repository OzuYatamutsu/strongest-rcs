#!/bin/bash
### Installation script, fish and bash
INSTALL_CWD=$PWD

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
go get gopkg.in/src-d/go-git.v4
go get github.com/shirou/gopsutil/disk
go get github.com/fatih/color
GO111MODULE=auto go build -o $CATESHELL_HOME/cateshell_welcome_screen .
GO111MODULE=auto go build -o $CATESHELL_HOME/colorize_fish_like fish/colorize_fish_like.go
GO111MODULE=auto go build -o $CATESHELL_HOME/colorize_bash_like bash/colorize_bash_like.go
GO111MODULE=auto go build -o $CATESHELL_HOME/colorize_powershell_like powershell/colorize_powershell_like.go
GO111MODULE=auto go build -o $CATESHELL_HOME/cateshell_prompt prompt/cateshell_prompt.go

# Install CATESHELL shell configs
sed "s|_CATESHELL_HOME|$CATESHELL_HOME|g" fish/cateshell_fish.fish \
  > cateshell_fish.fish.temp
mv -fv cateshell_fish.fish.temp "$CATESHELL_HOME/cateshell_fish.fish"
sed "s|_CATESHELL_HOME|$CATESHELL_HOME|g" bash/cateshell_bash.sh \
  > cateshell_bash.sh.temp
mv -fv cateshell_bash.sh.temp "$CATESHELL_HOME/cateshell_bash.sh"
sed "s|_CATESHELL_HOME|$CATESHELL_HOME|g" zsh/cateshell_zsh.sh \
  > cateshell_zsh.sh.temp
mv -fv cateshell_zsh.sh.temp "$CATESHELL_HOME/cateshell_zsh.sh"
sed "s|_CATESHELL_HOME|$CATESHELL_HOME|g" xonsh/cateshell_xonsh.py \
  > cateshell_xonsh.py.temp
mv -fv cateshell_xonsh.py.temp "$CATESHELL_HOME/cateshell_xonsh.py"

# Install CATESHELL scripts
mkdir ~/scripts || true
mkdir "$CATESHELL_HOME/scripts" || true
cp -Rfv scripts/* "$CATESHELL_HOME/scripts/"

# Point bash to bash CATESHELL config
touch ~/.bashrc
grep -q -F "source ${CATESHELL_HOME}/cateshell_bash.sh" ~/.bashrc \
  || echo "source ${CATESHELL_HOME}/cateshell_bash.sh" >> ~/.bashrc

# Point fish to fish CATESHELL config
mkdir "$HOME/.config/fish" || true
touch "$HOME/.config/fish/config.fish"
grep -q -F "source ${CATESHELL_HOME}/cateshell_fish.fish" "$HOME/.config/fish/config.fish" \
  || echo "source ${CATESHELL_HOME}/cateshell_fish.fish" >> "$HOME/.config/fish/config.fish"

# Point zsh to zsh CATESHELL config
touch ~/.zshrc
grep -q -F "source ${CATESHELL_HOME}/cateshell_zsh.sh" ~/.zshrc \
  || echo "source ${CATESHELL_HOME}/cateshell_zsh.sh" >> ~/.zshrc

# Point xonsh to xonsh CATESHELL config
touch ~/.xonshrc
grep -q -F "source ${CATESHELL_HOME}/cateshell_xonsh.py" ~/.xonshrc \
  || echo "source ${CATESHELL_HOME}/cateshell_xonsh.py" >> ~/.xonshrc
# Done.
