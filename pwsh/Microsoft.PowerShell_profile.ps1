# mute beep
Set-PSReadLineOption -BellStyle None
# bash like powershell completion
Set-PSReadlineKeyHandler -Key Tab -Function Complete
# load my own version of catppuccin theme
oh-my-posh init pwsh --config "$home/.config/oh-my-posh/catppuccin_macchiato.omp.json" | Invoke-Expression


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
