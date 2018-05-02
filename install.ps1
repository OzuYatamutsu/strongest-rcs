# Install Pathogen (plugin manager)
mkdir -p ~\vimfiles\autoload ~\vimfiles\bundle
curl -LSso ~\vimfiles\autoload\pathogen.vim https://tpo.pe/pathogen.vim

# Download vim-airline
If (Test-Path ~\vimfiles\bundle\vim-airline) {
  git clone https://github.com/vim-airline/vim-airline ~\vimfiles\bundle\vim-airline
} Else {
  Write-Host "vim-airline looks like it exists already; not cloning."
}

# Download vim-airline-themes
If (Test-Path ~\vimfiles\bundle\vim-airline-themes) {
  git clone https://github.com/vim-airline/vim-airline-themes ~\vimfiles\bundle\vim-airline-themes
} Else {
  Write-Host "vim-airline-themes looks like it exists already; not cloning."
}

cp profile.ps1 $profile
cp vimrc ~/.vimrc
cp cat_header ~/.cat_header

# Replace fish with powershell
(Get-Content ~/.vimrc).Replace("set shell=fish", "set shell=powershell") `
  | Set-Content ~/.vimrc
