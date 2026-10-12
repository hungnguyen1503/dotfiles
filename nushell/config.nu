# config.nu
#
# Installed by:
# version = "0.114.1"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# Nushell sets "sensible defaults" for most configuration settings, 
# so your `config.nu` only needs to override these defaults if desired.
#
# You can open this file in your default editor using:
#     config nu
#
# You can also pretty-print and page through the documentation for configuration
# options using:
#     config nu --doc | nu-highlight | less -R

# =============================================================================
# fzf / zoxide integration (binaries managed by winget)
# =============================================================================

# UI defaults for every fzf invocation (key bindings override append per-binding).
$env.FZF_DEFAULT_OPTS = '--layout=reverse --border=rounded --info=inline --prompt="❯ " --height=40% --min-height=12 --color=bg+:#3b4261,bg:#222437,spinner:#c0caf5,hl:#bb9af7,fg:#c0caf5,header:#7aa2f7,info:#414868,pointer:#c0caf5,marker:#c0caf5,fg+:#c0caf5,prompt:#bb9af7,hl+:#bb9af7,selected-bg:#2f334d'

# File picker preview (bat is on PATH from hungquangnguyen/Software).
$env.FZF_CTRL_T_OPTS = '--preview="bat --color=always --line-range=:300 {}" --preview-window=right:45%,wrap'

# --- zoxide: fuzzy directory jumping (`z foo`, `zi`; cd hook seeds the DB) ---
# Init scripts are (re)generated in env.nu, which runs before this file is
# parsed -- `source` resolves files at parse time, so they must pre-exist.
source ~/.zoxide.nu

# --- fzf: official nushell integration (generated in env.nu) ---
# CTRL-R history search, CTRL-T file insert, ALT-C dir jump, `**` + TAB completion.
source ~/.fzf.nu

# =============================================================================
# General Shell & Table Configuration
# =============================================================================
$env.config = ($env.config? | default {})
$env.config.show_banner = false

# Table display style for structured data
$env.config.table = ($env.config.table? | default {})
$env.config.table.mode = "rounded" # "rounded", "compact", "thin", "light"

# =============================================================================
# Keybindings (Ctrl+O to accept ghost text / completion suggestion)
# =============================================================================
$env.config.keybindings = (($env.config.keybindings? | default [] | where { |kb| ($kb.name? | default "") != "approve_suggestion" }) ++ [
    {
        name: approve_suggestion
        modifier: control
        keycode: char_o
        mode: [emacs, vi_insert, vi_normal]
        event: {
            until: [
                { send: historyhintcomplete }
                { send: menuright }
                { send: right }
            ]
        }
    }
])

# =============================================================================
# Aliases (Bash / Zsh style)
# =============================================================================
alias cd = z
alias cdi = zi
alias l = ls
alias la = ls -a
alias ll = ls -l
alias v = nvim
alias vi = nvim
alias vim = nvim
alias nv = neovide
alias lg = lazygit
alias g = git
alias c = clear


# =============================================================================
# Directory Listing Styles for Long Folders (Screen Overflow Alternatives)
# =============================================================================

# 1. Grid style: displays compact multi-column horizontal layout with icons & colors
#    Prevents long tables from scrolling past the top of the terminal buffer.
def lgrid [path: glob = "."] {
    ls $path | update name { |it| $it.name | path basename } | grid --icons --color name
}

# 2. Interactive pager: opens full structured directory list in interactive TUI pager
#    (Navigate with arrows/j/k, search with /, press q or Esc to exit).
def le [path: glob = "."] {
    ls $path | explore
}
