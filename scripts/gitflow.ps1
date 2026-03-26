param(
  [Parameter(Mandatory = $true)]
  [ValidateSet("init", "feature-start", "feature-finish", "release-start", "release-finish", "hotfix-start", "hotfix-finish")]
  [string]$Action,

  [string]$Name,
  [string]$Version,
  [switch]$Push
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Ensure-CleanWorktree {
  $status = git status --porcelain
  if ($status) {
    throw "Working tree is not clean. Commit or stash changes first."
  }
}

function Ensure-BranchExists([string]$Branch) {
  $exists = git branch --list $Branch
  if (-not $exists) {
    throw "Branch '$Branch' does not exist."
  }
}

function Checkout-Branch([string]$Branch) {
  git checkout $Branch
}

function Merge-NoFF([string]$Source, [string]$Target, [string]$Message) {
  Checkout-Branch $Target
  git merge --no-ff $Source -m $Message
}

function Push-Branch([string]$Branch) {
  git push -u origin $Branch
}

function Sync-Branch([string]$Branch) {
  Checkout-Branch $Branch
  git pull --ff-only origin $Branch
}

switch ($Action) {
  "init" {
    Ensure-CleanWorktree
    Checkout-Branch "main"
    if (-not (git branch --list "develop")) {
      git checkout -b develop
      if ($Push) { Push-Branch "develop" }
      git checkout main
    }
    if ($Push) { Push-Branch "main" }
    Write-Host "Git flow initialized. Branches: main, develop"
  }

  "feature-start" {
    if (-not $Name) { throw "Provide -Name for feature-start." }
    Ensure-CleanWorktree
    Ensure-BranchExists "develop"
    Sync-Branch "develop"
    $branch = "feature/$Name"
    git checkout -b $branch
    if ($Push) { Push-Branch $branch }
    Write-Host "Created $branch"
  }

  "feature-finish" {
    if (-not $Name) { throw "Provide -Name for feature-finish." }
    Ensure-CleanWorktree
    $branch = "feature/$Name"
    Ensure-BranchExists $branch
    Merge-NoFF $branch "develop" "merge($branch): into develop"
    git branch -d $branch
    if ($Push) {
      Push-Branch "develop"
      git push origin --delete $branch
    }
    Write-Host "Merged and removed $branch"
  }

  "release-start" {
    if (-not $Version) { throw "Provide -Version for release-start (example: 1.2.0)." }
    Ensure-CleanWorktree
    Ensure-BranchExists "develop"
    Sync-Branch "develop"
    $branch = "release/v$Version"
    git checkout -b $branch
    if ($Push) { Push-Branch $branch }
    Write-Host "Created $branch"
  }

  "release-finish" {
    if (-not $Version) { throw "Provide -Version for release-finish (example: 1.2.0)." }
    Ensure-CleanWorktree
    $branch = "release/v$Version"
    Ensure-BranchExists $branch

    Merge-NoFF $branch "main" "release(v$Version): merge into main"
    git tag "v$Version"

    Merge-NoFF "main" "develop" "sync(main): back-merge after release v$Version"

    git branch -d $branch

    if ($Push) {
      Push-Branch "main"
      Push-Branch "develop"
      git push origin "v$Version"
      git push origin --delete $branch
    }

    Write-Host "Release v$Version finished"
  }

  "hotfix-start" {
    if (-not $Version) { throw "Provide -Version for hotfix-start (example: 1.2.1)." }
    Ensure-CleanWorktree
    Sync-Branch "main"
    $branch = "hotfix/v$Version"
    git checkout -b $branch
    if ($Push) { Push-Branch $branch }
    Write-Host "Created $branch"
  }

  "hotfix-finish" {
    if (-not $Version) { throw "Provide -Version for hotfix-finish (example: 1.2.1)." }
    Ensure-CleanWorktree
    $branch = "hotfix/v$Version"
    Ensure-BranchExists $branch

    Merge-NoFF $branch "main" "hotfix(v$Version): merge into main"
    git tag "v$Version"

    Merge-NoFF "main" "develop" "sync(main): back-merge after hotfix v$Version"

    git branch -d $branch

    if ($Push) {
      Push-Branch "main"
      Push-Branch "develop"
      git push origin "v$Version"
      git push origin --delete $branch
    }

    Write-Host "Hotfix v$Version finished"
  }
}
