# Requires PowerShell 7 (pwsh). Repo must be cloned at %USERPROFILE%\dotfiles.
$ErrorActionPreference = 'Stop'

$expectedRoot = Join-Path $HOME 'dotfiles'
$repoRoot = (Resolve-Path $PSScriptRoot).Path
if ($repoRoot -ne $expectedRoot) {
    Write-Error "This repo must be cloned at $expectedRoot (found $repoRoot). Profiles and the gitconfig include depend on that fixed path."
}

$ts = Get-Date -Format 'yyyyMMdd-HHmmss'

# Repo dir -> Windows link target. Whole directory is junctioned.
$mappings = @(
    @{ repo = 'nushell';    target = Join-Path $env:APPDATA 'nushell' },
    @{ repo = 'lazygit';    target = Join-Path $env:APPDATA 'lazygit' },
    @{ repo = 'fastfetch';  target = Join-Path $env:APPDATA 'fastfetch' },
    @{ repo = 'herdr';      target = Join-Path $env:APPDATA 'herdr' },
    @{ repo = 'omp\agent';  target = Join-Path $HOME '.omp\agent' },
    @{ repo = 'wezterm';    target = Join-Path $HOME '.config\wezterm' },
    @{ repo = 'powershell'; target = Join-Path $HOME 'Documents\PowerShell' },
    @{ repo = 'nvim';       target = Join-Path $env:LOCALAPPDATA 'nvim' }
)

function Test-IsJunctionTo([string]$path, [string]$to) {
    if (-not (Test-Path -LiteralPath $path)) { return $false }
    $item = Get-Item -LiteralPath $path -Force
    if ($item.LinkType -ne 'Junction' -and $item.LinkType -ne 'SymbolicLink') { return $false }
    # Target is a string on some Windows builds and a string array on others.
    $linkedTo = @($item.Target)[0]
    if (-not $linkedTo) { return $false }
    return ([string]$linkedTo).TrimEnd('\') -ieq $to.TrimEnd('\')
}

foreach ($m in $mappings) {
    $repoDir = Join-Path $repoRoot $m.repo
    $target = $m.target
    if (-not (Test-Path -LiteralPath $repoDir)) {
        Write-Error "Repo directory missing: $repoDir"
    }

    if ($m.repo -eq 'omp\agent' -and -not (Test-IsJunctionTo $target $repoDir) -and
        (Get-Process -Name omp -ErrorAction SilentlyContinue)) {
        Write-Error "omp is running; quit every omp session, then re-run this script so $target can be linked."
    }

    if (Test-IsJunctionTo $target $repoDir) {
        Write-Output ("{0,-12} skipped  (already linked)" -f $m.repo)
        continue
    }

    if (Test-Path -LiteralPath $target) {
        # Move pre-existing state (anything not a link) into the repo dir so
        # nothing is lost, then rename leftovers to a backup.
        Get-ChildItem -LiteralPath $target -Force -ErrorAction SilentlyContinue |
            Where-Object { $_.LinkType -eq $null } |
            ForEach-Object {
                $dest = Join-Path $repoDir $_.Name
                if (-not (Test-Path -LiteralPath $dest)) {
                    Move-Item -LiteralPath $_.FullName -Destination $dest -Force
                }
            }
        if (Test-Path -LiteralPath $target) {
            Move-Item -LiteralPath $target -Destination "$target.bak-$ts"
            Write-Output ("{0,-12} backed up -> {1}.bak-{2}" -f $m.repo, $target, $ts)
        }
    }

    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $target) | Out-Null
    New-Item -ItemType Junction -Path $target -Target $repoDir | Out-Null
    Write-Output ("{0,-12} created  {1} -> {2}" -f $m.repo, $target, $repoDir)
}

# omp: secrets live in the linked agent dir's .env (gitignored), never in the
# repo. Seed it from the template so provider/MCP references resolve.
$ompEnv = Join-Path $HOME '.omp\agent\.env'
$ompExample = Join-Path $repoRoot 'omp\agent\.env.example'
if ((Test-Path -LiteralPath (Join-Path $HOME '.omp\agent')) -and
    -not (Test-Path -LiteralPath $ompEnv) -and
    (Test-Path -LiteralPath $ompExample)) {
    Copy-Item -LiteralPath $ompExample -Destination $ompEnv
    Write-Output "omp          created .env from .env.example — fill in the keys"
}

# .gitconfig: write the include stub (original was moved into git/gitconfig on
# the source machine; on fresh machines nothing else exists).
$gitconfig = Join-Path $HOME '.gitconfig'
$stub = "[include]`n    path = ~/dotfiles/git/gitconfig`n"
if (-not (Test-Path -LiteralPath $gitconfig)) {
    Set-Content -LiteralPath $gitconfig -Value $stub -NoNewline
    Write-Output "gitconfig    created include stub"
} elseif ((Get-Content -LiteralPath $gitconfig -Raw) -ne $stub) {
    Move-Item -LiteralPath $gitconfig -Destination "$gitconfig.bak-$ts"
    Set-Content -LiteralPath $gitconfig -Value $stub -NoNewline
    Write-Output "gitconfig    backed up + include stub written"
} else {
    Write-Output "gitconfig    skipped  (stub already in place)"
}

Write-Output "`nDone."
