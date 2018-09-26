### Installation script, powershell on Windows
$INSTALL_CWD = $PWD.Path

# CATESHELL requires python3 and pip3 to be defined.
# Fail immediately if this check doesn't pass.
if (!(which python3).Length) {
  Write-Host "CATESHELL requires Python >= 3.6, and 'python3' to be defined."
  Write-Host "Please remedy this situation manually."
  return
}

if (!(which pip3).Length) {
  Write-Host "CATESHELL requires Python >= 3.6, and 'pip3' to be defined."
  Write-Host "Please remedy this situation manually."
  return
}

# Where will CATESHELL live?
$env:CATESHELL_HOME = "$env:HOME/.config/cateshell"

# Clean this directory.
if (Test-Path "$env:CATESHELL_HOME") {
  Remove-Item -Recurse -Force -Verbose "$env:CATESHELL_HOME/*"
}

# Install dependencies
# Python dependencies
pip3 install -r requirements.txt --user

# - Create directory for vimfiles
If (!(Test-Path "$env:HOME/vimfiles")) {
  New-Item -ItemType Directory "$env:HOME/vimfiles"
  New-Item -ItemType Directory "$env:HOME/vimfiles/autoload"
  New-Item -ItemType Directory "$env:HOME/vimfiles/bundle"
}

# - Pathogen (plugin manager for vim)
Invoke-WebRequest https://tpo.pe/pathogen.vim -OutFile ~/vimfiles/autoload/pathogen.vim  >$null

# - vim-airline (styling for vim)
If (!(Test-Path "$env:HOME/vimfiles/bundle/vim-airline")) {
  # Install
  git clone https://github.com/vim-airline/vim-airline "$env:HOME/vimfiles/bundle/vim-airline"
} Else {
  # ...or update.
  Set-Location "$env:HOME/vimfiles/bundle/vim-airline"
  git pull
  Set-Location $INSTALL_CWD
}

# - vim-airline-themes (styling for vim)
If (!(Test-Path "$env:HOME/vimfiles/bundle/vim-airline-themes")) {
  # Install
  git clone https://github.com/vim-airline/vim-airline-themes "$env:HOME/vimfiles/bundle/vim-airline-themes"
} Else {
  # ...or update.
  Set-Location "$env:HOME/vimfiles/bundle/vim-airline-themes"
  git pull
  Set-Location $INSTALL_CWD
}

# Install vimrc and inject modifications
Copy-Item -Force -Verbose vimrc ~/.vimrc
(Get-Content vimrc).Replace("set shell=fish", "set shell=powershell") `
  | Set-Content ~/.vimrc

# Install CATESHELL core
If (!(Test-Path "$env:CATESHELL_HOME")) {
  New-Item -ItemType Directory "$env:CATESHELL_HOME"
}
Copy-Item -Force -Verbose cateshell_prompt.py "$env:CATESHELL_HOME"
Copy-Item -Force -Verbose cateshell_prompt.py "$env:CATESHELL_HOME"
Copy-Item -Force -Verbose cateshell_store.py "$env:CATESHELL_HOME"
Copy-Item -Force -Verbose cateshell_git_support.py "$env:CATESHELL_HOME"
Copy-Item -Force -Verbose cateshell_welcome_screen.py "$env:CATESHELL_HOME"
Copy-Item -Force -Verbose cateshell_cat_header.txt "$env:CATESHELL_HOME"

# Install CATESHELL bash config
(Get-Content cateshell_bash.sh).Replace("_CATESHELL_HOME", $env:CATESHELL_HOME) `
  | Set-Content cateshell_bash.sh.temp
Move-Item -Force -Verbose cateshell_bash.sh.temp `
  "$env:CATESHELL_HOME/cateshell_bash.sh"

# Install CATESHELL fish config
(Get-Content cateshell_fish.fish).Replace("_CATESHELL_HOME", $env:CATESHELL_HOME) `
  | Set-Content cateshell_fish.fish.temp
Move-Item -Force -Verbose cateshell_fish.fish.temp `
  "$env:CATESHELL_HOME/cateshell_fish.fish"

# Install CATESHELL powershell config
(Get-Content cateshell_powershell.ps1).Replace("_CATESHELL_HOME", $env:CATESHELL_HOME) `
  | Set-Content cateshell_powershell.ps1.temp
Move-Item -Force -Verbose cateshell_powershell.ps1.temp `
  "$env:CATESHELL_HOME/cateshell_powershell.ps1"

# Install CATESHELL health checks and plugins
If (!(Test-Path "$env:CATESHELL_HOME/health_checks")) {
  New-Item -ItemType Directory "$env:CATESHELL_HOME/health_checks"
}
Copy-Item -Recurse -Force -Verbose health_checks/*.py `
  "$env:CATESHELL_HOME/health_checks/"

If (!(Test-Path "$env:CATESHELL_HOME/plugins")) {
  New-Item -ItemType Directory "$env:CATESHELL_HOME/plugins"
}
Copy-Item -Recurse -Force -Verbose plugins/*.py `
  "$env:CATESHELL_HOME/plugins/"

# Install CATESHELL scripts
If (!(Test-Path "$env:HOME/scripts")) {
  New-Item -ItemType Directory "$env:HOME/scripts"
}
If (!(Test-Path "$env:CATESHELL_HOME/scripts")) {
  New-Item -ItemType Directory "$env:CATESHELL_HOME/scripts"
}
Copy-Item -Recurse -Force -Verbose scripts/*.py `
  "$env:CATESHELL_HOME/scripts/"

# Set current directory as update source
python3 "${env:CATESHELL_HOME}/cateshell_store.py" CATESHELL_HOME $env:CATESHELL_HOME
python3 "${env:CATESHELL_HOME}/cateshell_store.py" CATESHELL_SOURCE_DIR $PWD.Path

# Point powershell to powershell CATESHELL config TODO
(Get-Content $profile).Replace("TODO", "TODO") `
  | Set-Content $profile

# TODO remove this when figure out how to source in powershell
Copy-Item -Force -Verbose "$env:CATESHELL_HOME/cateshell_powershell.ps1" $profile
# Done.
