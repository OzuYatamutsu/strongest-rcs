# Install Pathogen (plugin manager)
$CATLAB_METADATA_DIR = "$env:USERPROFILE\.config\cateshell"
mkdir ~\vimfiles\autoload -ErrorAction SilentlyContinue >$null
mkdir ~\vimfiles\bundle -ErrorAction SilentlyContinue >$null
Invoke-WebRequest https://tpo.pe/pathogen.vim -OutFile ~\vimfiles\autoload\pathogen.vim  >$null

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

mkdir ~/.config -ErrorAction SilentlyContinue
mkdir ~/.config/cateshell -ErrorAction SilentlyContinue
mkdir ~/.config/cateshell/plugins -ErrorAction SilentlyContinue
mkdir ~/.config/cateshell/health_checks -ErrorAction SilentlyContinue
rm ~/.config/cateshell/*.py -Recurse -ErrorAction SilentlyContinue
rm ~/.config/cateshell/plugins/* -Recurse -ErrorAction SilentlyContinue
rm ~/.config/cateshell/health_checks/* -Recurse -ErrorAction SilentlyContinue

cp -fv cateshell_prompt.py ~/.config/fish/
cp -fv welcome_screen.py ~/.config/cateshell
cp -fv catelab_store.py ~/.config/cateshell
cp -fv git_support.py ~/.config/cateshell/
cp -fv cat_header ~/.config/cateshell/
cp health_checks/*.py ~/.config/cateshell/health_checks/
cp plugins/*.py ~/.config/cateshell/plugins/
pip3 install -r requirements.txt

# Set current directory as update directory
python3 "${CATLAB_METADATA_DIR}/catelab_store.py" CATLAB_METADATA_DIR $CATLAB_METADATA_DIR
python3 "${CATLAB_METADATA_DIR}/catelab_store.py" CATELAB_SOURCE_DIR $PWD.Path
python3 "${CATLAB_METADATA_DIR}/catelab_store.py" INSTALL_SOURCE_DIR $PWD.Path

# Replace fish with powershell
(Get-Content ~/.vimrc).Replace("set shell=fish", "set shell=powershell") `
  | Set-Content ~/.vimrc

# Set source dir
(Get-Content $profile).Replace("INSTALL_SOURCE_DIR", $PWD.Path) `
  | Set-Content $profile

