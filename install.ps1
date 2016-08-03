cp profile.ps1 $profile
cp vimrc ~/.vimrc

# Replace fish with powershell
(Get-Content ~/.vimrc).Replace("set shell=fish", "set shell=powershell") `
  | Set-Content ~/.vimrc
