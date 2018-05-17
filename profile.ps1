## Constants
$UP_ARROW = 8593 | %{[char] $_}
$DOWN_ARROW = 8595 | %{[char] $_}
$CROSS = "X"
$DELTA = 916 | %{[char] $_}
## End constants

## Shell formatting
#$shell.BackgroundColor = "Black"
#$shell.ForegroundColor = "DarkYellow"
#$shell.WindowTitle = "CateShell"
#$shell.BufferSize.Height = 3000
## End shell formatting

$env:CATLAB_SOURCE_DIR = "INSTALL_SOURCE_DIR"

## Welcome prompt
python3 $env:USERPROFILE\.config\cateshell\welcome_screen.py "$env:USERPROFILE\.config\cateshell"

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
  $added = $changes | Where-Object { $_[0] -ne " " -and $_[1] -ne "?"}
  if ($added -ne $null) { 
    if ($added.GetType().Name -eq "String") { return 1 } 
    return $added.Length 
  }
  return 0
}
function CheckNumUnaddedChanges {
  $changes = git status --porcelain
  if (!$? -or $changes -eq $null) { return 0 }
  $added = $changes | Where-Object { $_[1] -ne " " -and $_[1] -ne "?"}
  if ($added -ne $null) { 
    if ($added.GetType().Name -eq "String") { return 1 } 
    return $added.Length 
  }
  return 0
}
## End helper functions

function Prompt {
  Write-Host "$env:username@$env:computername " -nonewline -foregroundcolor "blue"
  Write-Host "$pwd".Replace($home, "~") -nonewline -foregroundcolor "green"
  if (CheckIfGitDirectory) {
    $branchName = (gc .git/HEAD).Replace("ref: refs/heads/", "") #git rev-parse --abbrev-ref HEAD
    $unpushedChanges = git log --oneline origin/$branchName..$branchName
    Write-Host " (" -nonewline
    Write-Host "$branchName" -nonewline -foregroundcolor "magenta"
   
    # Check for unpushed commits and display if > 0 
    $unpushed = CheckNumUnpushedCommits($branchName)

    # Check for uncommitted changes and display if > 0
    $added = CheckNumUncommittedChanges

    # Check for unadded changes and display if > 0
    $unstaged = CheckNumUnaddedChanges

    if ($unpushed -gt 0 -or $added -gt 0 -or $unstaged -gt 0) { Write-Host "|" -nonewline }
    if ($unpushed -gt 0) { Write-Host "$UP_ARROW$unpushed" -nonewline -foregroundcolor "green" }
    if ($added -gt 0) { Write-Host "+$added" -nonewline -foregroundcolor "green" }
    if ($unstaged -gt 0) { Write-Host "$DELTA$unstaged" -nonewline -foregroundcolor "yellow" }
    
    Write-Host ")" -nonewline
  }
  return "> "
}
