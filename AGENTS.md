# dotfiles

## 1. Project Overview

Cross-platform dotfiles repository configuring WezTerm, Nushell, PowerShell, Neovim, LazyGit, Fastfetch, and Herdr across Windows and Linux. Employs directory junctions on Windows and symlinks on Linux, requiring the repository to reside at `~/dotfiles`.

## 2. Key Constraints

- **Role & Scope**: Act as Cross-Platform Systems Engineer. Keep changes minimal, deterministic, and aligned with existing module seams.
- **Canonical Root Invariant**: Repository must be cloned at `~/dotfiles` (`%USERPROFILE%\dotfiles` on Windows, `$HOME/dotfiles` on Linux); profiles and Git include stubs depend on this fixed path.
- **Cross-Platform Parity**: Maintain dual-OS compatibility for Windows (PowerShell 7, NTFS junctions) and Linux (Bash, symlinks); never introduce OS-specific path breakage in shared configs.
- **Non-Destructive Linking**: Never delete or overwrite user configuration files; pre-existing files must be merged into the repo directory or preserved as `<target>.bak-<timestamp>`.
- **No Unverified Assumptions**: Never invent config keys, delete unrelated code, or bypass repository invariants.
- Long foreground calls may auto-background by the configured threshold; the result is injected as a follow-up when the job finishes. NEVER poll a backgrounded job (`sleep`, `ps`, `pgrep`, `top`) - do other work or end your reply and you will be woken with its output.

## 3. Additional Documentation

- **Architecture & Module Boundaries**: [.agents/docs/architecture.md](.agents/docs/architecture.md) — Read when navigating directories, interfaces, or component seams.
- **Cross-Platform Architecture**: [.agents/docs/cross-platform.md](.agents/docs/cross-platform.md) — Read when working on Cross-Platform Architecture.
- **Command: Windows Bootstrap**: [.agents/commands/bootstrap-windows.md](.agents/commands/bootstrap-windows.md) — Read when running Windows Bootstrap.
- **Command: Linux Bootstrap**: [.agents/commands/bootstrap-linux.md](.agents/commands/bootstrap-linux.md) — Read when running Linux Bootstrap.
- **Command: Submodule Sync**: [.agents/commands/submodule-update.md](.agents/commands/submodule-update.md) — Read when running Submodule Sync.
- **Coding Rule: Cross-Platform Compatibility**: [.agents/coding-rules/cross-platform.md](.agents/coding-rules/cross-platform.md) — Read for Cross-Platform Compatibility standards.
- **Coding Rule: Non-Destructive Linking**: [.agents/coding-rules/backup-safety.md](.agents/coding-rules/backup-safety.md) — Read for Non-Destructive Linking standards.
- **Workflow: Environment Bootstrap**: [.agents/workflows/bootstrap-setup.md](.agents/workflows/bootstrap-setup.md) — Read for step-by-step Environment Bootstrap procedures.
