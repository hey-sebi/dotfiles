<#  Link-Dotfiles.ps1

Usage:
  .\Link-Dotfiles.ps1 -RepoRoot 'C:\myrepos\dotfiles' [-DryRun] [-Verbose]

NOTE Add/modify entries in $Items below to manage more files.
#>

#requires -Version 5.1

[CmdletBinding(SupportsShouldProcess=$true)]
param(
  [Parameter(Mandatory)]
  [string]$RepoRoot,

  [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function New-Timestamp {
  (Get-Date -Format 'yyyyMMddHHmmss')
}

function Ensure-Dir([string]$Path) {
  if (-not [string]::IsNullOrWhiteSpace($Path)) {
    New-Item -ItemType Directory -Force -Path $Path | Out-Null
  }
}

function Is-Link([string]$Path) {
  if (-not (Test-Path -LiteralPath $Path)) { return $false }
  try {
    $itm = Get-Item -LiteralPath $Path -Force
    return ($null -ne $itm.LinkType) # works for symlinks/junctions
  } catch { return $false }
}

function Get-LinkTarget([string]$Path) {
  try { (Get-Item -LiteralPath $Path -Force).Target } catch { $null }
}

function Backup-Existing([string]$Path) {
  $ts = New-Timestamp
  $bak = "$Path.bak.$ts"
  Write-Host "  - Backing up existing to: $bak"
  if (-not $DryRun) { Move-Item -LiteralPath $Path -Destination $bak -Force }
}

function Link-Item([string]$Name, [string]$RepoRel, [string]$DestPath) {
  Write-Host "`n==> $Name"
  # TargetPath is the target of the symlink, i.e. the file in our repo
  $TargetPath = Join-Path -Path $RepoRoot -ChildPath $RepoRel
  $destDir = Split-Path -Parent $DestPath
  $repoDir = Split-Path -Parent $TargetPath

  Write-Verbose "TargetPath: $TargetPath"
  Write-Verbose "DestPath  : $DestPath"

  # If repo target missing but original exists, copy it into repo first
  if (-not (Test-Path -LiteralPath $TargetPath)) {
    if (Test-Path -LiteralPath $DestPath) {
      Write-Host "  - Config file not yet in repository; copying original."
      Write-Host "    $DestPath  ->  $TargetPath"
      if (-not $DryRun) {
        Ensure-Dir $repoDir
        Copy-Item -LiteralPath $DestPath -Destination $TargetPath -Force
      }
    } else {
      Write-Warning "  - Config file does neither exist in the repository or at the original location. Skipping."
      return
    }
  }

  # Ensure destination directory exists
  Ensure-Dir $destDir

  # If destination already correct link, done
  if (Is-Link $DestPath) {
    $currentTarget = Get-LinkTarget $DestPath
    if ($currentTarget -and (Resolve-Path -LiteralPath $currentTarget).Path -eq (Resolve-Path -LiteralPath $TargetPath).Path) {
      Write-Host "  - Already linked correctly. Skipping."
      return
    }
    Write-Host "  - Destination is a link to '$currentTarget' (will replace)."
    if (-not $DryRun) { Remove-Item -LiteralPath $DestPath -Force }
  } elseif (Test-Path -LiteralPath $DestPath) {
    Write-Host "  - Symlinking would overwrite an existing file. Creating backup.."
    Backup-Existing $DestPath
  }

  # Choose link type: directory → Junction, file → SymbolicLink
  $isDir = (Test-Path -LiteralPath $TargetPath -PathType Container)
  if ($isDir) { $linkType = 'Junction' } else { $linkType = 'SymbolicLink' }
  Write-Host "  - Creating ${linkType}:"
  Write-Host "    $DestPath  ->  $TargetPath"

  if (-not $DryRun) {
    New-Item -ItemType $linkType -Path $DestPath -Target $TargetPath | Out-Null
  }

  # Verify
  if (-not $DryRun) {
    $currentTarget = Get-LinkTarget $DestPath
    $resolvedCurrent = if ($currentTarget) { (Resolve-Path -LiteralPath $currentTarget -ErrorAction SilentlyContinue).Path }
    $resolvedTarget  = (Resolve-Path -LiteralPath $TargetPath).Path
    if ($resolvedCurrent -and $resolvedCurrent -eq $resolvedTarget) {
      Write-Host "  - OK."
    } else {
      Write-Warning "  - Link verification failed (saw: '$currentTarget')."
    }
  }
}

# --------------------------
# Define items to manage
# --------------------------
# Tip: Keep repo paths relative and tidy 
# Example layout:
#   <RepoRoot>\pwsh\Microsoft.PowerShell_profile.ps1
#   <RepoRoot>\git\.gitconfig
#   <RepoRoot>\vscode\settings.json
# Adjust/extend as you like & need.

$Items = @(
  @{
    Name    = 'PowerShell profile'
    RepoRel = 'pwsh\Microsoft.PowerShell_profile.ps1'
    Dest    = $PROFILE
  },
  @{
    Name    = 'Git bash config'
    RepoRel = 'git\.bashrc'
    Dest    = Join-Path $HOME '.bashrc'
  },
  @{
    Name    = 'Wezterm config'
    RepoRel = 'wezterm\wezterm.lua'
    Dest    = Join-Path $HOME '.config\wezterm\wezterm.lua'
  }
  # @{
  #   Name    = 'VS Code settings'
  #   RepoRel = 'vscode\settings.json'
  #   Dest    = Join-Path $env:APPDATA 'Code\User\settings.json'
  # }
  # Add more:
  # @{
  #   Name='SSH config'; RepoRel='ssh\config'; Dest=Join-Path $HOME '.ssh\config'
  # }
)

# Resolve RepoRoot once
$RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path
Write-Host "Using repository: $RepoRoot"
if ($DryRun) { Write-Host " >>> Dry run -- no changes will be made. <<<" }

foreach ($it in $Items) {
  Link-Item -Name $it.Name -RepoRel $it.RepoRel -DestPath $it.Dest
}

Write-Host "`nDone."
