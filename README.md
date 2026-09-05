# dotfiles

Personal configuration for wezterm, nushell, oh-my-posh, herdr, lazygit, git,
PowerShell, and nvim (as a git submodule). Works on Windows and Linux.

## Layout

| Directory | Windows target | Linux target |
|---|---|---|
| `wezterm/` | `%USERPROFILE%\.config\wezterm` | `~/.config/wezterm` |
| `nushell/` | `%APPDATA%\nushell` | `~/.config/nushell` |
| `oh-my-posh/` | referenced by the PowerShell profile | same |
| `herdr/` | `%APPDATA%\herdr` | `~/.config/herdr` |
| `lazygit/` | `%APPDATA%\lazygit` | `~/.config/lazygit` |
| `powershell/` | `%USERPROFILE%\Documents\PowerShell` | `~/.config/powershell` |
| `git/` | included via `~/.gitconfig` stub | same |
| `nvim/` | `%LOCALAPPDATA%\nvim` | `~/.config/nvim` |

Directories are junctions (Windows) or symlinks (Linux) into this repo, which
must live at `~/dotfiles`.

## Bootstrap

- Windows (PowerShell 7): `pwsh ./install.ps1`
- Linux: `./install.sh`

nvim is a submodule; if cloning fresh use:

```sh
git clone --recurse-submodules git@github.com:hungnguyen1503/dotfiles.git
```

Runtime state (nushell history, herdr sessions/logs) is gitignored but lives
inside the linked directories.
