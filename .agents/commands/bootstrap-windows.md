# Command: Windows Bootstrap

## 1. Purpose

Bootstrap the dotfiles configuration on Windows by creating NTFS directory junctions and configuring the global Git include stub.

## 2. Invocation

```powershell
pwsh ./install.ps1
```

## 3. Notes & Options

- **Prerequisites**: PowerShell 7 (`pwsh`). Windows PowerShell 5.1 is not supported.
- **Repository Path**: Must be cloned at `%USERPROFILE%\dotfiles`.
- **Privileges**: Runs with standard user privileges; NTFS directory junctions do not require elevated administrator rights.
- **Mapped Targets**:
  - `%APPDATA%\nushell` -> `nushell/`
  - `%APPDATA%\lazygit` -> `lazygit/`
  - `%APPDATA%\fastfetch` -> `fastfetch/`
  - `%APPDATA%\herdr` -> `herdr/`
  - `%USERPROFILE%\.omp\agent` -> `omp/agent/`
  - `%USERPROFILE%\.config\wezterm` -> `wezterm/`
  - `%USERPROFILE%\Documents\PowerShell` -> `powershell/`
  - `%LOCALAPPDATA%\nvim` -> `nvim/`
- **Git Config**: Writes stub to `%USERPROFILE%\.gitconfig` pointing to `~/dotfiles/git/gitconfig`.
- **omp**: Quit every running omp session first — Windows cannot relocate the agent dir's open sqlite files, so the first link fails while omp runs. Existing agent state (sessions, DBs, `.env`) is moved into `omp/agent/` and stays untracked. If `omp/agent/.env` is missing, the script seeds it from `.env.example`; fill in the provider keys and MCP tokens there, never in the tracked files.
