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
| `omp/` | `%USERPROFILE%\.omp\agent` | — (Windows only) |
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

Runtime state (nushell history, herdr sessions/logs, omp sessions/sqlite DBs) is
gitignored but lives inside the linked directories.

`omp/` is Windows-only: `config.yml`, `mcp.json`, and `lsp.json` carry absolute
Windows paths. Provider keys and MCP tokens are not committed — `models.yml` and
`mcp.json` reference environment-variable names, and the values live in
`~/.omp/agent/.env` (gitignored). Copy `omp/agent/.env.example` there and fill it
in on each machine.
