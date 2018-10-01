### C A T E S H E L L
### (xonsh implementation)
### ...by Sean Collins!

### CATELAB-SPECIFIC ENV VARIABLES
$CATESHELL_HOME = "_CATESHELL_HOME"

### OTHER ENV VARIABLES
$LC_ALL 'en_US.utf8'
$PATH.append('~/scripts')
$PATH.append('$CATESHELL_HOME/scripts')

### CATELAB-SPECIFIC FUNCTIONS
def cateshell_db(key=None, value=None):
    """Access CATESHELL config vars from db"""
    $key = key if key else ""
    $value = value if value else ""

    if $value:
        python3 "$CATESHELL_HOME/cateshell_store.py" $key $value > NUL
    elif $key:
        python3 "$CATESHELL_HOME/cateshell_store.py" $key
    else:
        python3 "$CATESHELL_HOME/cateshell_store.py"

def version_string():


## CATESHELL SHELL BUILT-IN FUNCTIONS
def version_string():
    xonsh --version

def current_shell():
    which xonsh

def get_utime_ms():
    import time
    print(int(time.time()*1000))

## PROMPT
def prompt():
    pass
    # printf (python3 "$CATESHELL_HOME/cateshell_prompt.py")

## WELCOME HEADER
def welcome_header():
    $NEXT_HEADER_UTIME = cateshell_db('FISHRC_NEXT_HEADER_UTIME')
    $NEXT_HEADER_UTIME = 0 if not $NEXT_HEADER_UTIME else int($NEXT_HEADER_UTIME)
    if get_utime_ms() < $NEXT_HEADER_UTIME:
        # Don't print header again
        return

    python3 "$CATESHELL_HOME/cateshell_welcome_screen.py" "$CATESHELL_HOME" version_string()
    cateshell_db('FISHRC_NEXT_HEADER_UTIME', get_utime_ms() + 500)

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
