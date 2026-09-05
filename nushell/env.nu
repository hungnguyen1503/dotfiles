# env.nu
#
# Installed by:
# version = "0.114.1"
#
# Previously, environment variables were typically configured in `env.nu`.
# In general, most configuration can and should be performed in `config.nu`
# or one of the autoload directories.
#
# This file is generated for backwards compatibility for now.
# It is loaded before config.nu and login.nu
#
# See https://www.nushell.sh/book/configuration.html
#
# Also see `help config env` for more options.
#
# You can remove these comments if you want or leave
# them for future reference.

# =============================================================================
# Generate shell-integration scripts before config.nu is parsed.
# Kept in sync with the installed (winget-managed) binaries on every startup.
# =============================================================================
zoxide init nushell | save --force ~/.zoxide.nu
fzf --nushell | save --force ~/.fzf.nu
