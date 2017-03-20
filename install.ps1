# Install Pathogen (plugin manager)
mkdir -p ~\vimfiles\autoload ~\vimfiles\bundle
curl -LSso ~\vimfiles\autoload\pathogen.vim https://tpo.pe/pathogen.vim

# Download vim-airline
git clone https://github.com/vim-airline/vim-airline ~\vimfiles\bundle\vim-airline

cp profile.ps1 $profile
cp vimrc ~/.vimrc

# Replace fish with powershell
(Get-Content ~/.vimrc).Replace("set shell=fish", "set shell=powershell") `
  | Set-Content ~/.vimrc
