# Architecture & Module Layout (`dotfiles`)

## 1. Overview

- **Repository**: `dotfiles`
- **Primary Stack**: Shell scripting (Bash, PowerShell 7, Nushell), Lua (WezTerm, Neovim)
- **Canonical Location**: `~/dotfiles` (`%USERPROFILE%\dotfiles` on Windows, `$HOME/dotfiles` on Linux)
- **Submodules**: `nvim/` tracking Neovim configuration repository

## 2. Component & Directory Layout

| Directory | Subsystem / Tool | Windows Target | Linux Target |
| :--- | :--- | :--- | :--- |
| `wezterm/` | Terminal emulator config (`wezterm.lua`) | `%USERPROFILE%\.config\wezterm` | `~/.config/wezterm` |
| `nushell/` | Structured shell (`config.nu`, `env.nu`) | `%APPDATA%\nushell` | `~/.config/nushell` |
| `powershell/` | PowerShell 7 profile (`Microsoft.PowerShell_profile.ps1`) | `%USERPROFILE%\Documents\PowerShell` | `~/.config/powershell` |
| `lazygit/` | Terminal Git UI configuration (`config.yml`) | `%APPDATA%\lazygit` | `~/.config/lazygit` |
| `fastfetch/` | System information display (`config.jsonc`) | `%APPDATA%\fastfetch` | `~/.config/fastfetch` |
| `neofetch/` | Legacy system info display (`config.conf`) | — | `~/.config/neofetch` |
| `herdr/` | Session manager & multiplexer configs | `%APPDATA%\herdr` | `~/.config/herdr` |
| `git/` | Global git configuration (`gitconfig`) | Included in `~/.gitconfig` | Included in `~/.gitconfig` |
| `oh-my-posh/` | Prompt themes (`M365Princess.omp.json`) | Sourced by PowerShell profile | Sourced by profile |
| `nvim/` | Neovim IDE configuration (git submodule) | `%LOCALAPPDATA%\nvim` | `~/.config/nvim` |
| `archive/` | Deprecated configurations and backups | — | — |

## 3. Entrypoints & Data Flow

1. **Bootstrap Scripts**:
   - Windows: `install.ps1` validates repo path, backs up conflicting files, and creates NTFS directory junctions.
   - Linux: `install.sh` validates repo path, backs up conflicting files, and creates symlinks.
2. **Git Configuration Inclusion**:
   - Both installers write a minimal stub to `~/.gitconfig`:
     `[include] path = ~/dotfiles/git/gitconfig`
3. **Shell Startup Flow**:
   - Nushell: `env.nu` executes `zoxide init` and `fzf --nushell` to regenerate `~/.zoxide.nu` and `~/.fzf.nu` before `config.nu` parses and sources them.
   - PowerShell: `Microsoft.PowerShell_profile.ps1` initializes `oh-my-posh`, adds Git Bash function on Windows, and configures corporate CA certs if present.
   - WezTerm: `wezterm.lua` branches via `wezterm.target_triple` to set OS-specific default directories and binary paths.
