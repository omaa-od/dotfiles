$ErrorActionPreference = "Stop"

$Dotfiles = Split-Path -Parent $MyInvocation.MyCommand.Path

$GitConfigSource = Join-Path $Dotfiles "git\.gitconfig"
$GitConfigTarget = Join-Path $HOME ".gitconfig"

if (Test-Path $GitConfigSource) {
    if (Test-Path $GitConfigTarget) {
        Copy-Item $GitConfigTarget "$GitConfigTarget.backup" -Force
    }

    Copy-Item $GitConfigSource $GitConfigTarget -Force
    Write-Host ".gitconfig installé."
}

$ScriptsSource = Join-Path $Dotfiles "windows\scripts"

if (Test-Path $ScriptsSource) {
    $ScriptsTarget = Join-Path $HOME "dotfiles-scripts"

    New-Item -ItemType Directory -Force -Path $ScriptsTarget | Out-Null

    Copy-Item "$ScriptsSource\*" $ScriptsTarget -Recurse -Force

    Write-Host "Scripts Windows installés."
}

Write-Host "Installation terminée."
