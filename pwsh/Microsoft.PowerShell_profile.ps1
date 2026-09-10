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