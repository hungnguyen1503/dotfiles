# Coding Rule: Non-Destructive Linking

## 1. Scope & Intent

Guarantees backward compatibility and prevents data loss when linking dotfile directories or bootstrapping new machines across Windows and Linux.

## 2. Rule Standards

1. **Pre-Existing File Migration**:
   - Before replacing any target directory with a link, copy/move pre-existing non-link files into the corresponding repository directory so custom configurations are retained.
2. **Timestamped Backups**:
   - Any target directory or file that must be replaced must be renamed to `<target>.bak-<timestamp>` using format `yyyyMMdd-HHmmss` (e.g. `fastfetch.bak-20261012-143000`).
   - Never run recursive deletes (`rm -rf`, `Remove-Item -Recurse`) on unverified directories.
3. **Idempotent Link Detection**:
   - Always test whether the target is already a valid link/junction pointing to the repository.
   - If already pointing to the repository, skip linking and log `skipped (already linked)`.
4. **Gitconfig Safety**:
   - Check `~/.gitconfig` contents before writing the stub.
   - If `~/.gitconfig` exists and does not match the include stub, back it up to `~/.gitconfig.bak-<timestamp>` before writing the stub.

## 3. Enforcement & Verification

- Both `install.ps1` and `install.sh` must implement these exact preservation steps.
- Any new mapped directory added to `install.ps1` or `install.sh` must follow this workflow.
