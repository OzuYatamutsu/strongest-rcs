### C A T E S H E L L
### (xonsh implementation)
### ...by Sean Collins!

### CATELAB-SPECIFIC ENV VARIABLES
$CATESHELL_HOME = "_CATESHELL_HOME"

### OTHER ENV VARIABLES
$LC_ALL = 'en_US.utf8'
$PATH.append('~/scripts')
$PATH.append('$CATESHELL_HOME/scripts')

### Source PATH var on Mac
from os.path import isfile
from re import match
if isfile('/usr/libexec/path_helper'):
    path_entries = match('PATH="(.+?)"', $(/usr/libexec/path_helper)).group(1)
    for dir in path_entries.split(':'):
        $PATH.append(dir)

### CATELAB-SPECIFIC FUNCTIONS
def cateshell_db(key=None, value=None):
    """Access CATESHELL config vars from db"""
    $key = key if key else ""
    $value = value if value else ""

    if $value:
        return $(python3 "$CATESHELL_HOME/cateshell_store.py" $key $value > NUL)
    elif $key:
        return $(python3 "$CATESHELL_HOME/cateshell_store.py" $key)
    else:
        return $(python3 "$CATESHELL_HOME/cateshell_store.py")

## CATESHELL SHELL BUILT-IN FUNCTIONS
def version_string():
    return $(xonsh --version).strip()

def current_shell():
    return $(which xonsh).strip()

def get_utime_ms():
    import time
    return int(time.time()*1000)

## PROMPT
def prompt():
    pass
    # return $(python3 "$CATESHELL_HOME/cateshell_prompt.py" --xonsh)

## WELCOME HEADER
def welcome_header():
    $NEXT_HEADER_UTIME = cateshell_db('FISHRC_NEXT_HEADER_UTIME')
    $NEXT_HEADER_UTIME = 0 if not $NEXT_HEADER_UTIME else int($NEXT_HEADER_UTIME)
    if get_utime_ms() < $NEXT_HEADER_UTIME:
        return

    python3 "$CATESHELL_HOME/cateshell_welcome_screen.py" "$CATESHELL_HOME" @(version_string())
    cateshell_db('FISHRC_NEXT_HEADER_UTIME', get_utime_ms() + 500)

### XONSH-SPECIFIC IMPLEMENTATION
welcome_header()
