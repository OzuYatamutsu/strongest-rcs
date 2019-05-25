### C A T E S H E L L
### (fish implementation)
### ...by Sean Collins!

### NOTES
# Don't use export, use set --export for backwards compatibility
# Catelab requires Python>=3.6 to work properly

### CATELAB-SPECIFIC ENV VARIABLES
set --export CATESHELL_HOME "_CATESHELL_HOME"

### OTHER ENV VARIABLES
set --export LC_ALL 'en_US.utf8'
set -gx PATH ~/scripts $CATESHELL_HOME/scripts $PATH

## CATESHELL SHELL BUILT-IN FUNCTIONS
function version_string
  fish --version | head -n1
end

function current_shell
  which fish
end

function get_utime_ms
  python -c "import time; print(int(time.time()*1000))"
end

function colorize
  $CATESHELL_HOME/colorize_fish_like $argv
end

## PROMPT
function prompt
  printf (colorize ($CATESHELL_HOME/cateshell_prompt))
end

## WELCOME HEADER
function welcome_header
  $CATESHELL_HOME/cateshell_welcome_screen (version_string)
end

### FISH-SPECIFIC IMPLEMENTATION
function bind_bang
  switch (commandline -t)
  case "!"
    commandline -t $history[1]; commandline -f repaint
  case "*"
    commandline -i !
  end
end

function bind_dollar
  switch (commandline -t)
  case "!"
    commandline -t ""
    commandline -f history-token-search-backward
  case "*"
    commandline -i '$'
  end
end

function fish_user_key_bindings
  bind ! bind_bang
  bind '$' bind_dollar
end

function fish_prompt
  prompt
end

# No greet
set fish_greeting ""
welcome_header
