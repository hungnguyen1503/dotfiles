# Command: Submodule Sync

## 1. Purpose

Synchronize and update embedded git submodules (specifically `nvim/`) across machines.

## 2. Invocation

```bash
git submodule update --init --recursive
```

## 3. Notes & Options

- **Target**: Initializes and fetches commits for the `nvim/` submodule tracked in `.gitmodules`.
- **Clean Clone**: On a new environment, clone using `git clone --recurse-submodules <url>` to clone the root repo and initialize submodules in a single step.
