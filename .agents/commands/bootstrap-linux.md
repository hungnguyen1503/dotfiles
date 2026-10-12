# Command: Linux Bootstrap

## 1. Purpose

Bootstrap the dotfiles configuration on Linux by creating symbolic links and configuring the global Git include stub.

## 2. Invocation

```bash
bash ./install.sh
```

## 3. Notes & Options

- **Prerequisites**: Bash shell (`/usr/bin/env bash`), `find`, `readlink`, standard coreutils.
- **Repository Path**: Must be cloned at `$HOME/dotfiles`.
- **Mapped Targets**:
  - `~/.config/nushell` -> `nushell/`
  - `~/.config/lazygit` -> `lazygit/`
  - `~/.config/herdr` -> `herdr/`
  - `~/.config/neofetch` -> `neofetch/`
  - `~/.config/wezterm` -> `wezterm/`
  - `~/.config/powershell` -> `powershell/`
  - `~/.config/nvim` -> `nvim/`
- **Git Config**: Writes stub to `~/.gitconfig` pointing to `~/dotfiles/git/gitconfig`.
