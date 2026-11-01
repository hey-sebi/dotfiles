# mute beep
Set-PSReadLineOption -BellStyle None
# bash like powershell completion
Set-PSReadlineKeyHandler -Key Tab -Function Complete
# Starship prompt
if (-not (Get-Command starship -ErrorAction SilentlyContinue)) {
  $wingetPath = "$env:LOCALAPPDATA\Microsoft\WinGet\Links"
  if (Test-Path $wingetPath) { $env:PATH = "$wingetPath;$env:PATH" }
}
if (Get-Command starship -ErrorAction SilentlyContinue) {
  Invoke-Expression (&starship init powershell)
}

# File styling: bold foreground blue for directories (remove default blue background block)
if ($PSStyle) {
  $PSStyle.FileInfo.Directory = "`e[34;1m"
}

function UnmountMlrNetworkDirs { net use * /delete }
Set-Alias -Name unmountall -Value UnmountMlrNetworkDirs

Set-Alias -Name lg -Value lazygit

# Ensure modern posh-git on pwsh even if choco installed an old one
# TODO: this should be removed once there is a proper choco package
if ($PSVersionTable.PSEdition -eq 'Core') {
  $needModern = -not (Get-Module -ListAvailable posh-git | Where-Object { $_.Version -ge [version]'1.0.0' })
  if ($needModern) {
    try {
      PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force -ErrorAction Stop
    } catch {
      Write-Warning "Could not install modern posh-git: $_"
    }
  }
}
Import-Module posh-git

# zoxide setup
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# Fast Node Manager (fnm) cd hook:
fnm env --use-on-cd | Out-String | Invoke-Expression

# Activate MSVC Developer Shell (x64 / x86) on demand
function vsdev {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [ValidateSet("64", "32", "x64", "x86", "amd64", "-64", "-32", "-x64", "-x86")]
        [string]$Arch,

        [switch]$x86,
        [switch]$x64
    )

    if ($x86) { $Arch = "32" }
    elseif ($x64) { $Arch = "64" }

    if ($Arch) {
        $Arch = $Arch.TrimStart("-")
    }

    if (-not $Arch) {
        Write-Host "Select MSVC Target Architecture:" -ForegroundColor Cyan
        Write-Host "  [1] 64-bit (x64) [default]"
        Write-Host "  [2] 32-bit (x86)"
        $choice = Read-Host "Choice [1/2]"
        if ($choice -eq "2" -or $choice -eq "32" -or $choice -eq "x86") {
            $Arch = "32"
        } else {
            $Arch = "64"
        }
    }

    $targetArch = if ($Arch -eq "32" -or $Arch -eq "x86") { "x86" } else { "x64" }

    $vsPath = & vswhere -products * -latest -property installationPath
    if (-not $vsPath) {
        Write-Error "Visual Studio / BuildTools installation not found via vswhere."
        return
    }

    $dllPath = "$vsPath\Common7\Tools\Microsoft.VisualStudio.DevShell.dll"
    if (Test-Path $dllPath) {
        Import-Module $dllPath -ErrorAction Stop
        Write-Host "Activating MSVC ($targetArch) environment..." -ForegroundColor Green
        Enter-VsDevShell -VsInstallPath $vsPath -DevCmdArguments "-arch=$targetArch -host_arch=x64" -SkipAutomaticLocation
    } else {
        Write-Error "Could not find Microsoft.VisualStudio.DevShell.dll at $dllPath"
    }
}