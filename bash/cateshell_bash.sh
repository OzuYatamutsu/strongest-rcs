### C A T E S H E L L
### (bash implementation)
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
  bash --version | head -n1
}

function current_shell() {
  echo $SHELL
}

function get_utime_ms() {
  python -c "import time; print(int(time.time()*1000))"
}

function colorize() {
  $CATESHELL_HOME/colorize_fish_like $@
}

## PROMPT
function prompt() {
  colorize $("$CATESHELL_HOME/cateshell_prompt")
}

## WELCOME HEADER
function welcome_header {
  if [ ! -e ~/.NEXT_HEADER_UTIME ]; then
    echo '0' > ~/.NEXT_HEADER_UTIME
  fi

  NEXT_HEADER_UTIME=$(cat ~/.NEXT_HEADER_UTIME)

  if [ "$(get_utime_ms)" -lt "$NEXT_HEADER_UTIME" ]; then
    # Don't print header again
    return
  fi

  eval "$CATESHELL_HOME/cateshell_welcome_screen" "$(eval version_string)"
  echo $(( $(get_utime_ms) + 500 )) > ~/.NEXT_HEADER_UTIME
}

### BASH-SPECIFIC IMPLEMENTATIONS
function bash_print_prompt() {
    printf "$(prompt) "
}
PS1="\$(bash_print_prompt)"

welcome_header
if shopt -q login_shell; then
  welcome_header
fi
