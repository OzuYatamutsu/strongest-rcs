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

### CATELAB-SPECIFIC FUNCTIONS
function cateshell_db --description 'Access CATESHELL config vars from db'
  if test (count $argv) -eq 2
    python3 "$CATESHELL_HOME/cateshell_store.py" $argv 2>&1 >/dev/null
  else
    python3 "$CATESHELL_HOME/cateshell_store.py" $argv
  end
end

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
  python3 "$CATESHELL_HOME/colorize_bash_like.py" $argv
end
## PROMPT
function prompt
  printf (colorize (python3 "$CATESHELL_HOME/cateshell_prompt.py"))
end

## WELCOME HEADER
function welcome_header
  set NEXT_HEADER_UTIME (cateshell_db FISHRC_NEXT_HEADER_UTIME)
  if [ "$NEXT_HEADER_UTIME" = '' ]
    set NEXT_HEADER_UTIME '0'
  end
  if [ (get_utime_ms) -lt $NEXT_HEADER_UTIME ]
    # Don't print header again
    return
  end

  python3 "$CATESHELL_HOME/cateshell_welcome_screen.py" "$CATESHELL_HOME" (version_string)
  cateshell_db FISHRC_NEXT_HEADER_UTIME (math (get_utime_ms) + 500)
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
