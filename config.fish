### C A T E L A B
### (fish implementation)
### ...by Sean Collins!

### NOTES
# Don't use export, use set --export for backwards compatibility
# Catelab requires Python>=3.6 to work properly

### CATELAB-SPECIFIC ENV VARIABLES
set --export CATELAB_METADATA_DIR "$HOME/.config/fish"

### OTHER ENV VARIABLES
set --export LC_ALL 'en_US.utf8'
set -gx PATH ~/scripts $PATH

### CATELAB-SPECIFIC FUNCTIONS
function catelab_db --description 'Access Catelab config vars from db'
  if test (count $argv) -eq 2
    python3 "$CATELAB_METADATA_DIR/catelab_store.py" $argv 2>&1 >/dev/null
  else
    python3 "$CATELAB_METADATA_DIR/catelab_store.py" $argv
  end
end

## CATELAB SHELL BUILT-IN FUNCTIONS
function current_shell
  which fish
end

function get_utime_ms
  python -c "import time; print(int(time.time()*1000))"
end

## PROMPT
function prompt
  printf (python3 "$CATELAB_METADATA_DIR/cateshell_prompt.py")
end

## WELCOME HEADER
function welcome_header
  set NEXT_HEADER_UTIME (catelab_db FISHRC_NEXT_HEADER_UTIME)
  if [ "$NEXT_HEADER_UTIME" = '' ]
    set NEXT_HEADER_UTIME '0'
  end
  if [ (get_utime_ms) -lt $NEXT_HEADER_UTIME ]
    # Don't print header again
    return
  end

  python3 "$CATELAB_METADATA_DIR/welcome_screen.py" "$CATELAB_METADATA_DIR"
  catelab_db FISHRC_NEXT_HEADER_UTIME (math (get_utime_ms) + 100)
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
