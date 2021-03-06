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

## CATESHELL SHELL BUILT-IN FUNCTIONS
function version_string {
  "PowerShell $($PSVersionTable.PSVersion)"
}
function current_shell {
  (Get-Command powershell).Path
}

function get_utime_ms {
  python -c "import time; print(int(time.time()*1000))"
}

function colorize {
  $result = (& "$env:CATESHELL_HOME/colorize_powershell_like.exe" $args)
  $result = $result.Replace("\x1b", "$([char]27)")
  $result = $result.Replace("<SYM:UP>", "$([char]0x2191)")
  $result = $result.Replace("<SYM:DOWN>", "$([char]0x2193)")
  $result = $result.Replace("<SYM:ADD>", "$([char]0x002B)")
  $result = $result.Replace("<SYM:CHG>", "$([char]0x0394)")
  $result = $result.Replace("<SYM:UNTRACKED>", "$([char]0x2026)")

  return $result
}

## PROMPT
function Prompt {
  colorize (& $env:CATESHELL_HOME/cateshell_prompt.exe)
}

## WELCOME HEADER
function welcome_header {
  If ($NEXT_HEADER_UTIME -eq '') {
    $NEXT_HEADER_UTIME = "0"
  }
  If ((get_utime_ms) -lt $NEXT_HEADER_UTIME) {
    # Don't print header again
    return
  }

  & "$env:CATESHELL_HOME/cateshell_welcome_screen.exe" (version_string)
}

### POWERSHELL-SPECIFIC IMPLEMENTATION
# Aliases
New-Alias ll Get-ChildItem

function tail { Get-Content -Wait -Path $args }
function sh { Invoke-Expression "$args" }
function touch { Write-Host $null >> $args }

welcome_header
