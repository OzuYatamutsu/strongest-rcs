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

## CATESHELL SHELL BUILT-IN FUNCTIONS
def version_string():
    return $(xonsh --version).strip()

def current_shell():
    return $(which xonsh).strip()

def get_utime_ms():
    import time
    return int(time.time()*1000)

def colorize(input_str):
    from re import sub

    # Process symbols first
    input_str = sub(r'<SYM:UP>', '↑', input_str)
    input_str = sub(r'<SYM:DOWN>', '↓', input_str)
    input_str = sub(r'<SYM:ADD>', '+', input_str)
    input_str = sub(r'<SYM:CHG>', 'Δ', input_str)
    input_str = sub(r'<SYM:UNTRACKED>', '…', input_str)

    # Then colors
    input_str = sub(r'\<(.+?)\>', r'{\1}', input_str)
    input_str = sub(r'{BOLD:', r'{BOLD_', input_str)
    return input_str

## PROMPT
def prompt():
    return colorize($("$CATESHELL_HOME/cateshell_prompt"))\
        .strip() + ' '

## WELCOME HEADER
def welcome_header():
    "$CATESHELL_HOME/cateshell_welcome_screen" "$CATESHELL_HOME" @(version_string())

### XONSH-SPECIFIC IMPLEMENTATION
welcome_header()
$PROMPT = lambda: prompt()
