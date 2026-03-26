param(
  [string]$Message = "chore: bootstrap frontend repository",
  [switch]$Push
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

git add .
git commit -m $Message

if (-not (git branch --list develop)) {
  git branch develop
}

if ($Push) {
  git push -u origin main
  git push -u origin develop
}

Write-Host "Bootstrap complete: initial commit created, develop branch ensured."
