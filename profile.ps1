## Welcome prompt
$psVersion = $PSVersionTable.PSVersion.ToString()
$clrVersion = $PSVersionTable.CLRVersion.ToString()
$curDt = Get-Date

Write-Host "PowerShell $psVersion on .NET $clrVersion"
Write-Host "Heya, " -nonewline
Write-Host "$env:username" -nonewline -foregroundcolor "darkgreen"
Write-Host "! It's currently " -nonewline 
Write-Host $curDt -nonewline -foregroundcolor "red" 
Write-Host ". "
Write-Host "What will your " -nonewline
Write-Host "first sequence of the day " -nonewline -foregroundcolor "blue"
Write-Host "be?"
## End welcome prompt

## Aliases
New-Alias ll Get-ChildItem
## End Aliases

## Helper functions
function CheckIfGitDirectory {
  git rev-parse --git-dir > $null
  return $?
}
## End helper functions

function Prompt {
  Write-Host "$env:username@$env:computername " -nonewline -foregroundcolor "blue"
  Write-Host "$pwd" -nonewline -foregroundcolor "green"
  if (CheckIfGitDirectory) {
    $branchName = git rev-parse --abbrev-ref HEAD
    Write-Host " (" -nonewline
    Write-Host "$branchName" -nonewline -foregroundcolor "magenta"
    Write-host ")" -nonewline
  }
  return "> "
}
