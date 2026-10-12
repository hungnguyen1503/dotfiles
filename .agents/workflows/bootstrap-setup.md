# Workflow: Environment Bootstrap

## 1. Purpose

Comprehensive setup workflow for bootstrapping and verifying the dotfiles environment on fresh Windows or Linux machines, or after re-linking.

## 2. Execution Steps

1. **Clone Repository & Submodules**:
   - Ensure the repository is located strictly at `~/dotfiles`:
     ```bash
     git clone --recurse-submodules <repo-url> ~/dotfiles
     # Or if already cloned:
     git submodule update --init --recursive
     ```
2. **Execute Platform Installer**:
   - **Windows (PowerShell 7)**:
     ```powershell
     pwsh ./install.ps1
     ```
   - **Linux (Bash)**:
     ```bash
     bash ./install.sh
     ```
3. **Verify Links & Junctions**:
   - Windows: Verify junctions in `$env:APPDATA`, `$env:LOCALAPPDATA`, and `$HOME\.config`.
   - Linux: Verify symlinks in `~/.config/`.
4. **Verify Git Configuration**:
   - Ensure `~/.gitconfig` contains:
     ```gitconfig
     [include]
         path = ~/dotfiles/git/gitconfig
     ```
5. **Initialize Shell Integrations**:
   - Launch `nu` to verify `env.nu` generates `~/.zoxide.nu` and `~/.fzf.nu` and `config.nu` starts without syntax errors.

## 3. Verification & Completion

- Run installer a second time to verify idempotency (all mappings report `skipped (already linked)`).
- Verify git status in `~/dotfiles` remains clean and untracked files are not generated in git directories.
