#!/usr/bin/env bash
# Linux bootstrap. Repo must be cloned at ~/dotfiles.
set -euo pipefail

EXPECTED_ROOT="$HOME/dotfiles"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ "$REPO_ROOT" != "$EXPECTED_ROOT" ]]; then
    echo "This repo must be cloned at $EXPECTED_ROOT (found $REPO_ROOT)." >&2
    echo "Profiles and the gitconfig include depend on that fixed path." >&2
    exit 1
fi

TS="$(date +%Y%m%d-%H%M%S)"

# Repo dir -> Linux symlink target. Whole directory is symlinked.
mappings=(
    "nushell:$HOME/.config/nushell"
    "lazygit:$HOME/.config/lazygit"
    "herdr:$HOME/.config/herdr",
    "neofetch:$HOME/.config/neofetch",
    "wezterm:$HOME/.config/wezterm"
    "powershell:$HOME/.config/powershell"
    "nvim:$HOME/.config/nvim"
)

is_link_to() { # $1 path, $2 target
    [[ -L "$1" && "$(readlink -f "$1")" == "$(readlink -f "$2")" ]]
}

for pair in "${mappings[@]}"; do
    repo="${pair%%:*}"
    target="${pair#*:}"
    repo_dir="$REPO_ROOT/$repo"
    if [[ ! -d "$repo_dir" ]]; then
        echo "Repo directory missing: $repo_dir" >&2
        exit 1
    fi

    if is_link_to "$target" "$repo_dir"; then
        printf '%-12s skipped  (already linked)\n' "$repo"
        continue
    fi

    if [[ -e "$target" && ! -L "$target" ]]; then
        # Move pre-existing files into the repo dir so nothing is lost.
        find "$target" -mindepth 1 -maxdepth 1 | while read -r entry; do
            dest="$repo_dir/$(basename "$entry")"
            [[ -e "$dest" ]] || mv "$entry" "$dest"
        done
        if [[ -e "$target" ]]; then
            mv "$target" "$target.bak-$TS"
            printf '%-12s backed up -> %s.bak-%s\n' "$repo" "$target" "$TS"
        fi
    elif [[ -L "$target" ]]; then
        rm "$target"
    fi

    mkdir -p "$(dirname "$target")"
    ln -s "$repo_dir" "$target"
    printf '%-12s created  %s -> %s\n' "$repo" "$target" "$repo_dir"
done

# neofetch: install via the available package manager if missing.
if ! command -v neofetch >/dev/null 2>&1; then
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get install -y neofetch
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y neofetch
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --noconfirm neofetch
    else
        echo "neofetch     not found; install it manually" >&2
    fi
else
    echo "neofetch     skipped  (already installed)"
fi

# .gitconfig: write the include stub.
gitconfig="$HOME/.gitconfig"
stub=$'[include]\n    path = ~/dotfiles/git/gitconfig\n'
if [[ ! -e "$gitconfig" ]]; then
    printf '%s' "$stub" > "$gitconfig"
    echo "gitconfig    created include stub"
elif [[ "$(cat "$gitconfig")" != "$(printf '%s' "$stub")" ]]; then
    mv "$gitconfig" "$gitconfig.bak-$TS"
    printf '%s' "$stub" > "$gitconfig"
    echo "gitconfig    backed up + include stub written"
else
    echo "gitconfig    skipped  (stub already in place)"
fi

echo
echo "Done."
