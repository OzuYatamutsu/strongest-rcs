### Installation script, powershell on Windows
$INSTALL_CWD = $PWD.Path

# CATESHELL requires python3 and pip3 to be defined.
# Fail immediately if this check doesn't pass.
Try {
  Get-Command python3
} Catch {
  Write-Host "CATESHELL requires Python >= 3.6, and 'python3' to be defined."
  Write-Host "Please remedy this situation manually."
  return
}

Try {
  Get-Command pip3
} Catch {
  Write-Host "CATESHELL requires Python >= 3.6, and 'pip3' to be defined."
  Write-Host "Please remedy this situation manually."
  return
}

# Where will CATESHELL live?
$env:CATESHELL_HOME = "$env:USERPROFILE/.config/cateshell"

# Clean this directory.
if (Test-Path "$env:CATESHELL_HOME") {
  Remove-Item -Recurse -Force -Verbose "$env:CATESHELL_HOME/*"
}

# Install dependencies
# Python dependencies
pip3 install -r requirements.txt --user

# - Create directory for vimfiles
If (!(Test-Path "$env:USERPROFILE/vimfiles")) {
  New-Item -ItemType Directory "$env:USERPROFILE/vimfiles"
  New-Item -ItemType Directory "$env:USERPROFILE/vimfiles/autoload"
  New-Item -ItemType Directory "$env:USERPROFILE/vimfiles/bundle"
}

# - Pathogen (plugin manager for vim)
Invoke-WebRequest https://tpo.pe/pathogen.vim -OutFile ~/vimfiles/autoload/pathogen.vim  >$null

# - vim-airline (styling for vim)
If (!(Test-Path "$env:USERPROFILE/vimfiles/bundle/vim-airline")) {
  # Install
  git clone https://github.com/vim-airline/vim-airline "$env:USERPROFILE/vimfiles/bundle/vim-airline"
} Else {
  # ...or update.
  Set-Location "$env:USERPROFILE/vimfiles/bundle/vim-airline"
  git pull
  Set-Location $INSTALL_CWD
}

# - vim-airline-themes (styling for vim)
If (!(Test-Path "$env:USERPROFILE/vimfiles/bundle/vim-airline-themes")) {
  # Install
  git clone https://github.com/vim-airline/vim-airline-themes "$env:USERPROFILE/vimfiles/bundle/vim-airline-themes"
} Else {
  # ...or update.
  Set-Location "$env:USERPROFILE/vimfiles/bundle/vim-airline-themes"
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

go get gopkg.in/src-d/go-git.v4
go get github.com/shirou/gopsutil/disk
go get github.com/fatih/color
go build -o "$env:CATESHELL_HOME/cateshell_welcome_screen.exe" cateshell_welcome_screen.go
go build -o "$env:CATESHELL_HOME/colorize_fish_like.exe" colorize_fish_like.go
go build -o "$env:CATESHELL_HOME/colorize_bash_like.exe" colorize_bash_like.go
go build -o "$env:CATESHELL_HOME/colorize_powershell_like.exe" colorize_powershell_like.go
go build -o "$env:CATESHELL_HOME/cateshell_prompt.exe" cateshell_prompt.go

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

# Install CATESHELL zsh config
(Get-Content cateshell_zsh.sh).Replace("_CATESHELL_HOME", $env:CATESHELL_HOME) `
  | Set-Content cateshell_zsh.sh.temp
Move-Item -Force -Verbose cateshell_zsh.sh.temp `
  "$env:CATESHELL_HOME/cateshell_zsh.sh"

# Install CATESHELL powershell config
(Get-Content cateshell_powershell.ps1).Replace("_CATESHELL_HOME", $env:CATESHELL_HOME) `
  | Set-Content cateshell_powershell.ps1.temp
Move-Item -Force -Verbose cateshell_powershell.ps1.temp `
  "$env:CATESHELL_HOME/cateshell_powershell.ps1"

# Install CATESHELL scripts
If (!(Test-Path "$env:HOME/scripts")) {
  New-Item -ItemType Directory "$env:HOME/scripts"
}
If (!(Test-Path "$env:CATESHELL_HOME/scripts")) {
  New-Item -ItemType Directory "$env:CATESHELL_HOME/scripts"
}
Copy-Item -Recurse -Force -Verbose scripts/*.py `
  "$env:CATESHELL_HOME/scripts/"

# Point powershell to powershell CATESHELL config
If (!("$(Get-Content -Raw $profile)".Contains(". '$env:CATESHELL_HOME/cateshell_powershell.ps1'"))) {
  Write-Output ". '$env:CATESHELL_HOME/cateshell_powershell.ps1'" >> $profile
}

# Colorization support in native PowerShell terminal
Set-ItemProperty HKCU:\Console VirtualTerminalLevel -Type DWORD 1

# Done.
