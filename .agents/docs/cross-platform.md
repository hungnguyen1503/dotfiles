# Cross-Platform Architecture (`dotfiles`)

## 1. Overview

This repository operates simultaneously across Windows and Linux environments without divergence or branch fragmentation. Configuration modules are linked directly into platform-specific configuration directories while the single source of truth remains in `~/dotfiles`.

## 2. Linking & Filesystem Mechanics

| Platform | Linking Mechanism | Elevated Privileges Required | Handling Existing State |
| :--- | :--- | :--- | :--- |
| **Windows** | NTFS Directory Junctions (`New-Item -ItemType Junction`) | No (Junctions do not require developer mode / admin) | Migrates non-link files into repo, moves original to `<target>.bak-<ts>` |
| **Linux** | Symbolic Links (`ln -s`) | No | Migrates non-link files into repo, moves original to `<target>.bak-<TS>` |

- **Strict Path Requirement**: The repository must be cloned at `~/dotfiles` (`%USERPROFILE%\dotfiles` on Windows, `$HOME/dotfiles` on Linux). Both `install.ps1` and `install.sh` verify this on invocation.
- **Git Config Include Stub**: Rather than symlinking `~/.gitconfig`, both installers write a non-destructive stub:
  ```gitconfig
  [include]
      path = ~/dotfiles/git/gitconfig
  ```
  Pre-existing divergent `~/.gitconfig` files are backed up to `~/.gitconfig.bak-<timestamp>`.

## 3. Dual-OS Runtime Adaptations

1. **WezTerm (`wezterm/wezterm.lua`)**:
   - Detects platform via `wezterm.target_triple:find("windows")`.
   - Windows sets default CWD to Windows project paths and locates binaries (`nu.exe`, `herdr.exe`) under `%LOCALAPPDATA%\Programs\...`.
   - Linux falls back to standard `$HOME` and PATH-based binaries (`nu`, `herdr`).
2. **Nushell (`nushell/env.nu` and `nushell/config.nu`)**:
   - `env.nu` runs early on both platforms, executing `zoxide init` and `fzf --nushell` into `~/.zoxide.nu` and `~/.fzf.nu`.
   - `config.nu` parses with cross-platform keybindings and sources the generated integration files.
   - External plugins: Do not compile via `cargo` in local Windows environments; rely on prebuilt releases.
3. **PowerShell (`powershell/Microsoft.PowerShell_profile.ps1`)**:
   - Requires PowerShell 7 (`pwsh`).
   - Uses `$IsWindows` guard to expose `bash` (Git Bash binary wrapper) only on Windows.
   - Conditionally loads corporate proxy CA certificates when detected in `$env:USERPROFILE\.pi\...`.

## 4. Backward Compatibility Invariants

- **Idempotence**: Running bootstrap scripts multiple times must skip existing valid links without error or duplicate backups.
- **State Preservation**: Dynamic cache/session data inside mapped tools (e.g., nushell history, herdr session files) is gitignored and must not be purged when re-linking.
