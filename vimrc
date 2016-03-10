set tabstop=4 softtabstop=4 expandtab shiftwidth=4 smarttab
syntax enable
set nocp
set shell=fish
set number         " line numbers
set showcmd        " show last command below
set wildmenu       " cycle through command matches (TAB)  
set showmatch      " highlight matching [{()}]
set incsearch      " search as characters are entered
set hlsearch       " highlight matched characters
set ruler          " Show line and character numbers
set statusline+=%F " Always show full file path 

" tmux will send xterm-style keys when its xterm-keys option is on
if &term =~ '^screen'
    execute "set <xUp>=\e[1;*A"
    execute "set <xDown>=\e[1;*B"
    execute "set <xRight>=\e[1;*C"
    execute "set <xLeft>=\e[1;*D"
endif
