### C A T E L A B
### (bash implementation)
### ...by Sean Collins!

### NOTES
# Catelab requires Python>=3.6 to work properly

### CATELAB-SPECIFIC ENV VARIABLES
export CATELAB_METADATA_DIR="$HOME/.config/fish"

### OTHER ENV VARIABLES
export LC_ALL='en_US.utf8'
export PATH=~/scripts:$PATH

### CATELAB-SPECIFIC FUNCTIONS
function catelab_db {  # Access Catelab config vars from db
    if [ "$#" -eq 2 ]; then
      python3 "$CATELAB_METADATA_DIR/catelab_store.py" $@ 2>&1 >/dev/null
    else
      python3 "$CATELAB_METADATA_DIR/catelab_store.py" $@
    fi
}

## CATELAB SHELL BUILT-IN FUNCTIONS
function current_shell() {
  echo $SHELL
}

function get_utime_ms() {
  python -c "import time; print(int(time.time()*1000))"
}

## PROMPT
function prompt() {
  python3 "$CATELAB_METADATA_DIR/cateshell_prompt.py"
}

## WELCOME HEADER
function welcome_header() {
  NEXT_HEADER_UTIME="$(catelab_db BASHRC_NEXT_HEADER_UTIME)"
  if [[ "$NEXT_HEADER_UTIME" == '' ]]; then
    NEXT_HEADER_UTIME='0'
  fi
  if [ "$(get_utime_ms)" -lt "$NEXT_HEADER_UTIME" ]; then
    # Don't print header again
    return
  fi

  python3 "${CATELAB_METADATA_DIR}/welcome_screen.py" "${CATELAB_METADATA_DIR}"
  catelab_db BASHRC_NEXT_HEADER_UTIME "$(get_utime_ms + 100)"
}

### BASH-SPECIFIC IMPLEMENTATIONS
PS1=$(printf "$(prompt)")

welcome_header
if shopt -q login_shell; then
  welcome_header
fi
