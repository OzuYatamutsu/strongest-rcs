### C A T E S H E L L
### (zsh implementation)
### ...by Sean Collins!

### NOTES
# CATESHELL requires Python>=3.6 to work properly

### CATESHELL-SPECIFIC ENV VARIABLES
export CATESHELL_HOME="_CATESHELL_HOME"

### OTHER ENV VARIABLES
export LC_ALL='en_US.utf8'
export PATH=~/scripts:$CATESHELL_HOME/scripts:$PATH

## CATESHELL SHELL BUILT-IN FUNCTIONS
function version_string() {
  zsh --version | head -n1
}

function current_shell() {
  which zsh
}

function get_utime_ms() {
  python -c "import time; print(int(time.time()*1000))"
}

function colorize() {
  "$CATESHELL_HOME/colorize_bash_like" $@
}

## PROMPT
function prompt() {
  # TODO zsh is running into the same issue bash was
  colorize $("$CATESHELL_HOME/cateshell_prompt") | sed 's/\x1b/\[\\x1b/'
}

## WELCOME HEADER
function welcome_header() {
  NEXT_HEADER_UTIME="$(cateshell_db BASHRC_NEXT_HEADER_UTIME)"
  if [[ "$NEXT_HEADER_UTIME" == '' ]]; then
    NEXT_HEADER_UTIME='0'
  fi
  if [ "$(get_utime_ms)" -lt "$NEXT_HEADER_UTIME" ]; then
    # Don't print header again
    return
  fi

  "${CATESHELL_HOME}/cateshell_welcome_screen" "${CATESHELL_HOME}" "$(version_string)"
  cateshell_db BASHRC_NEXT_HEADER_UTIME "$(get_utime_ms + 500)"
}

### ZSH-SPECIFIC IMPLEMENTATIONS
function precmd() {
  PROMPT=$(printf "$(prompt)")
}

welcome_header
