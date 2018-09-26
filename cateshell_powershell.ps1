### C A T E S H E L L
### (powershell implementation)
### ...by Sean Collins!

### NOTES
# Catelab requires Python>=3.6 to work properly

### CATELAB-SPECIFIC ENV VARIABLES
$env:CATESHELL_HOME = "_CATESHELL_HOME"

### OTHER ENV VARIABLES
$env:LC_ALL = "en_US.utf8"
$env:PATH = "$env:USERPROFILE/scripts:" + "$env:CATESHELL_HOME/scripts:" + $env:PATH

### CATELAB-SPECIFIC FUNCTIONS
function cateshell_db {
  # Access CATESHELL config vars from db
  if ($argv.Length == 2) {
    python3 "$env:CATESHELL_HOME/cateshell_store.py" $argv 2>&1 >/dev/null
  } else {
    python3 "$env:CATESHELL_HOME/cateshell_store.py" $argv
  }
}

## CATESHELL SHELL BUILT-IN FUNCTIONS
function current_shell {
  which pwsh  # TODO
}

function get_utime_ms {
  python -c "import time; print(int(time.time()*1000))"
}

## PROMPT
function prompt {
  printf (python3 "$env:CATESHELL_HOME/cateshell_prompt.py")
}

## WELCOME HEADER
function welcome_header {
  $NEXT_HEADER_UTIME = (cateshell_db PWSHRC_NEXT_HEADER_UTIME)
  if ($NEXT_HEADER_UTIME == '') {
    $NEXT_HEADER_UTIME = "0"
  }
  if ((get_utime_ms) -lt $NEXT_HEADER_UTIME) {
    # Don't print header again
    return
  }

  python3 "$CATESHELL_HOME/cateshell_welcome_screen.py" "$CATESHELL_HOME"
  cateshell_db PWSHRC_NEXT_HEADER_UTIME (get_utime_ms + 100)
}

### POWERSHELL-SPECIFIC IMPLEMENTATION
# Aliases
New-Alias ll Get-ChildItem
function tail { Get-Content -Wait -Path $args }
function sh { Invoke-Expression "$args" }
function touch { Write-Host $null >> $args }

function Prompt {
  (python3 $env:CATESHELL_HOME/cateshell_prompt.py).Replace("\x1b", "$([char]27)")
}

python3 $env:CATESHELL_HOME/cateshell_welcome_screen.py $env:CATESHELL_HOME