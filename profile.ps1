## Constants
$UP_ARROW = 8593 | %{[char] $_}
$DOWN_ARROW = 8595 | %{[char] $_}
$CROSS = "X"

## End constants

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
function tail { Get-Content -Wait -Path $args }
function sh { Invoke-Expression "$args" }
function touch { echo $null >> $args }
## End Aliases

## Helper functions
function CheckIfGitDirectory {
  git rev-parse --git-dir > $null
  return $?
}
function CheckNumUnpushedCommits {
  param ([string] $branch)

  $unpushed = git log --oneline origin/$branch..$branch
  if ($? -and $unpushed -ne $null) { return $unpushed.Split("`n").Length }
  else { return 0 } # e.g. branch doesn't exist upstream
}
function CheckNumUncommittedChanges {
  $changes = git status --porcelain
  if (!$? -or $changes -eq $null) { return 0 }
  $added = $changes | Where-Object { $_[0] -ne " "}
  if ($added -ne $null) { return $added.Length }
  return 0
}
## End helper functions

function Prompt {
  Write-Host "$env:username@$env:computername " -nonewline -foregroundcolor "blue"
  Write-Host "$pwd".Replace($home, "~") -nonewline -foregroundcolor "green"
  if (CheckIfGitDirectory) {
    $branchName = git rev-parse --abbrev-ref HEAD
    $unpushedChanges = git log --oneline origin/$branchName..$branchName
    Write-Host " (" -nonewline
    Write-Host "$branchName" -nonewline -foregroundcolor "magenta"
   
    # Check for unpushed commits and display if > 0 
    $unpushed = CheckNumUnpushedCommits($branchName)
    if ($unpushed -gt 0) { Write-Host "$UP_ARROW$unpushed" -nonewline -foregroundcolor "green" }

    # Check for uncommitted changes and display if > 0
    $added = CheckNumUncommittedChanges
    if ($added -gt 0) { Write-Host "+$added" -nonewline -foregroundcolor "green" }

    Write-Host ")" -nonewline
  }
  return "> "
}
