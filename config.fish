### NOTES
# Don't use export, use set --export for backwards compatibility
# Catelab requires Python>=3.6 to work properly

### COLOR DEFINITIONS
set normal (set_color normal)
set magenta (set_color magenta)
set yellow (set_color yellow)
set green (set_color green)
set red (set_color red)
set gray (set_color -o black)

### ENV VARIABLES
set --export CATELAB_METADATA_DIR "$HOME/.config/fish"

### OTHER ENV
set --export LC_ALL 'en_US.utf8'
set -gx PATH ~/scripts $PATH

### CONFIG DB
function catelab_db --description 'Access Catelab config vars from db'
  if test (count $argv) -eq 2
    python3 "$CATELAB_METADATA_DIR/catelab_store.py" $argv 2>&1 >/dev/null
  else
    python3 "$CATELAB_METADATA_DIR/catelab_store.py" $argv
  end
end

### START !!, !$ bash support
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
## END !!, !$ bash support

## Aliases and various functions
function is_git_repo
  set -l is_inside_work_tree (git rev-parse --is-inside-work-tree ^/dev/null )

  if test -z $is_inside_work_tree
    echo 'false'
  else
    echo 'true'
  end
end

function get_utime_ms
  python -c "import time; print(int(time.time()*1000))"
end
## END Aliases and various functions

function user_hostname_prompt --description "Displays the username and the hostname"
    echo -n "$USER@"
    echo -n (hostname -s)
    echo -n " "
end

function prompt_long_pwd --description 'Print the current working directory'
    echo $PWD | sed -e "s|^$HOME|~|" -e 's|^/private||'
end

function git_prompt --description 'Print git information'
  set_color normal
  python3 "$CATELAB_METADATA_DIR/git_support.py" 
end

function fish_prompt
  # User + hostname
  set last_status $status
  set_color magenta
  printf '%s' (user_hostname_prompt)

  # CWD
  set_color $fish_color_cwd
  printf '%s' (prompt_long_pwd)

  # Git status
  if test 'true' = (is_git_repo)
    printf ' '
    printf (git_prompt)
  end

  # End prompt
  set_color normal
  echo -n "> "
end

function emphasize_text
  set_color $argv[1]; printf $argv[2]; set_color normal
end

function welcome_text
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

set fish_greeting ""  # No greet
welcome_text
