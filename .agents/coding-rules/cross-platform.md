# Coding Rule: Cross-Platform Compatibility

## 1. Scope & Intent

Ensures all configuration files, helper scripts, and automation work seamlessly across Windows and Linux without breaking existing workflows or requiring separate OS branches.

## 2. Rule Standards

1. **Path Handling**:
   - Never hardcode Windows-specific drive letters or backslash paths in shared configurations (`wezterm.lua`, `config.nu`, `config.yml`).
   - In PowerShell, use `Join-Path $HOME ...` or `$env:USERPROFILE`.
   - In Bash, use `$HOME` or `$(dirname "$0")`.
   - In WezTerm Lua, guard paths using `wezterm.target_triple:find("windows")`.
2. **Line Endings & Formats**:
   - Shell scripts (`install.sh`, `*.sh`) MUST maintain LF line endings.
   - PowerShell scripts (`install.ps1`) must be valid UTF-8.
3. **Linking Parity**:
   - On Windows, use NTFS directory junctions (`New-Item -ItemType Junction`) which do not require Administrator or Developer Mode.
   - On Linux, use standard directory symbolic links (`ln -s`).
   - Shared config directories must map to the canonical location `~/dotfiles`.
4. **Shell Script Safety**:
   - Bash scripts must declare `set -euo pipefail`.
   - PowerShell scripts must declare `$ErrorActionPreference = 'Stop'`.

## 3. Enforcement & Verification

- Review any modified configuration against both Windows target paths (`%APPDATA%`, `%LOCALAPPDATA%`, `%USERPROFILE%`) and Linux target paths (`~/.config`).
- Test script parsing in `pwsh` and `bash` before committing.
