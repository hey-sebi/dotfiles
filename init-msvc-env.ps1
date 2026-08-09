# This file sets up the relevant environment to enable usage of MSVC (from VS Build Tools) in a powershell.
#
# Usage: call this script with the dot operator to source its environment variables:
#
# . .\init-msvc-env.ps1

# 1. Early-exit guard
if (Test-Path env:VCINSTALLDIR) {
    Write-Host "VS Build Environment is already loaded." -ForegroundColor Yellow
    exit
}

# 2. Dynamically locate VS2019 Build Tools using vswhere
$vsWherePath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
if (-not (Test-Path $vsWherePath)) {
    Write-Error "vswhere.exe not found. Is Visual Studio Installer installed?"
    exit 1
}

$vsInstallProps = &$vsWherePath -version "[16.0,17.0)" -products Microsoft.VisualStudio.Product.BuildTools -format json | ConvertFrom-Json

if (-not $vsInstallProps) {
    Write-Error "VS2019 Build Tools installation could not be located."
    exit 1
}

$basePath = $vsInstallProps.installationPath
$instanceId = $vsInstallProps.instanceId
$modulePath = "$basePath\Common7\Tools\Microsoft.VisualStudio.DevShell.dll"

# 3. Import and execute using strict VS2019 parameters
if (Test-Path $modulePath) {
    Import-Module $modulePath

    # -SkipAutomaticLocation stops VS2019 from overriding your current directory.
    # -DevCmdArguments handles the x64 cross-compiler targeting x86 architecture.
    Enter-VsDevShell -VsInstanceId $instanceId -SkipAutomaticLocation -DevCmdArguments "-arch=x86 -host_arch=amd64"

    Write-Host "VS2019 Build Tools x86 environment loaded." -ForegroundColor Cyan
} else {
    Write-Error "DevShell.dll missing from expected path: $modulePath"
    exit 1
}
