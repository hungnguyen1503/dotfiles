<#
.SYNOPSIS
    Cross-platform CLI tool updater for Windows (PowerShell 7).
.DESCRIPTION
    Installs and updates Neovim, Neovide, Lazygit, Ripgrep, Fd, Zoxide, Fzf, and Fastfetch.
    Uses WinGet for user-scoped packages and GitHub releases for portable binaries.
#>

[CmdletBinding()]
param(
    [switch]$CheckOnly
)

$ErrorActionPreference = 'Stop'

Write-Host "=== Dotfiles CLI Tool Updater (Windows) ===" -ForegroundColor Cyan

# 1. Update WinGet user packages
$wingetPackages = @(
    @{ Id = "ajeetdsouza.zoxide"; Name = "zoxide" },
    @{ Id = "junegunn.fzf"; Name = "fzf" },
    @{ Id = "Fastfetch-cli.Fastfetch"; Name = "fastfetch" },
    @{ Id = "JesseDuffield.lazygit"; Name = "lazygit" },
    @{ Id = "BurntSushi.ripgrep.MSVC"; Name = "ripgrep" },
    @{ Id = "sharkdp.fd"; Name = "fd" }
)

Write-Host "`n[1/3] Checking & Updating WinGet Packages..." -ForegroundColor Yellow
foreach ($pkg in $wingetPackages) {
    Write-Host "  -> Processing $($pkg.Name) ($($pkg.Id))..."
    if (-not $CheckOnly) {
        try {
            winget install --id $pkg.Id --scope user --accept-source-agreements --accept-package-agreements --upgrade-if-available 2>&1 | Out-Null
        } catch {
            Write-Warning "Failed to install/upgrade $($pkg.Name) via WinGet: $_"
        }
    }
}

# 2. Sync to local Software directory if present (preserves legacy PATH ordering)
$softwareDir = Join-Path $env:USERPROFILE "hungquangnguyen\Software"
if (Test-Path $softwareDir) {
    Write-Host "`n[2/3] Synchronizing updated binaries to $softwareDir..." -ForegroundColor Yellow
    $wingetRoot = Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Packages"

    # Sync rg.exe
    $rgBin = Get-ChildItem -Path $wingetRoot -Filter "rg.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    $destRgDirs = Get-ChildItem -Path $softwareDir -Filter "*ripgrep*" -Directory -ErrorAction SilentlyContinue
    if ($rgBin -and $destRgDirs) {
        foreach ($dir in $destRgDirs) {
            Copy-Item -Path $rgBin.FullName -Destination (Join-Path $dir.FullName "rg.exe") -Force -ErrorAction SilentlyContinue
        }
    }

    # Sync lazygit.exe
    $lgBin = Get-ChildItem -Path $wingetRoot -Filter "lazygit.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    $destLgDir = Join-Path $softwareDir "lazygit"
    if ($lgBin -and (Test-Path $destLgDir)) {
        Copy-Item -Path $lgBin.FullName -Destination (Join-Path $destLgDir "lazygit.exe") -Force -ErrorAction SilentlyContinue
    }

    # Sync fd.exe
    $fdBin = Get-ChildItem -Path $wingetRoot -Filter "fd.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    $destFdDir = Join-Path $softwareDir "fd"
    if ($fdBin -and (Test-Path $destFdDir)) {
        Copy-Item -Path $fdBin.FullName -Destination (Join-Path $destFdDir "fd.exe") -Force -ErrorAction SilentlyContinue
    }
}

# 3. Update Neovim & Neovide from GitHub Release Archives
Write-Host "`n[3/3] Checking Portable GitHub Releases (Neovim & Neovide)..." -ForegroundColor Yellow

function Update-GitHubZip {
    param(
        [string]$Repo,
        [string]$AssetPattern,
        [string]$TargetDir,
        [string]$SubFolderInZip = ""
    )

    try {
        $api = "https://api.github.com/repos/$Repo/releases/latest"
        $release = Invoke-RestMethod -Uri $api
        $asset = $release.assets | Where-Object { $_.name -match $AssetPattern } | Select-Object -First 1

        if (-not $asset) {
            Write-Warning "No asset matching $AssetPattern found for $Repo"
            return
        }

        Write-Host "  -> $Repo latest: $($release.tag_name) ($($asset.name))"
        if ($CheckOnly) { return }

        $tempZip = Join-Path $env:TEMP "$($asset.name)"
        $tempExtract = Join-Path $env:TEMP "extract_$($asset.name)"
        if (Test-Path $tempExtract) { Remove-Item -Recurse -Force $tempExtract }

        Write-Host "     Downloading $($asset.browser_download_url)..."
        Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $tempZip
        Expand-Archive -Path $tempZip -DestinationPath $tempExtract -Force

        $source = if ($SubFolderInZip) { Join-Path $tempExtract $SubFolderInZip } else { $tempExtract }
        if (Test-Path $TargetDir) {
            Copy-Item -Path "$source\*" -Destination $TargetDir -Recurse -Force
        }

        Remove-Item -Force $tempZip -ErrorAction SilentlyContinue
        Remove-Item -Recurse -Force $tempExtract -ErrorAction SilentlyContinue
        Write-Host "     Updated $Repo to $($release.tag_name) successfully." -ForegroundColor Green
    } catch {
        Write-Warning "Failed to update $($Repo): $_"
    }
}

$destNvim = Join-Path $softwareDir "nvim-win64"
if (Test-Path $destNvim) {
    Update-GitHubZip -Repo "neovim/neovim" -AssetPattern "^nvim-win64\.zip$" -TargetDir $destNvim -SubFolderInZip "nvim-win64"
}

$destNeovide = Join-Path $softwareDir "neovide-windows"
if (Test-Path $destNeovide) {
    Update-GitHubZip -Repo "neovide/neovide" -AssetPattern "^neovide\.exe\.zip$" -TargetDir $destNeovide
}

Write-Host "`n=== Current Tool Versions ===" -ForegroundColor Cyan
@("nvim", "neovide", "lazygit", "zoxide", "fzf", "rg", "fd", "fastfetch") | ForEach-Object {
    $cmd = Get-Command $_ -ErrorAction SilentlyContinue
    if ($cmd) {
        $v = try { (& $cmd.Source --version 2>&1 | Select-Object -First 1) } catch { "unknown" }
        Write-Host ("{0,-12} : {1}" -f $_, $v)
    } else {
        Write-Host ("{0,-12} : NOT FOUND" -f $_) -ForegroundColor Red
    }
}
