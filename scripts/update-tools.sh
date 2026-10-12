#!/usr/bin/env bash
# Dotfiles CLI Tool Updater for Linux
# Installs/updates Neovim, Lazygit, Ripgrep, Fd, Zoxide, Fzf, and Fastfetch.

set -euo pipefail

BIN_DIR="${HOME}/.local/bin"
mkdir -p "${BIN_DIR}"
export PATH="${BIN_DIR}:${PATH}"

ARCH=$(uname -m)
case "${ARCH}" in
    x86_64)
        NVIM_ARCH="linux-x86_64"
        FZF_ARCH="linux_amd64"
        RG_ARCH="x86_64-unknown-linux-musl"
        FD_ARCH="x86_64-unknown-linux-musl"
        LG_ARCH="x86_64"
        ;;
    aarch64|arm64)
        NVIM_ARCH="linux-arm64"
        FZF_ARCH="linux_arm64"
        RG_ARCH="aarch64-unknown-linux-gnu"
        FD_ARCH="aarch64-unknown-linux-musl"
        LG_ARCH="arm64"
        ;;
    *)
        echo "Unsupported architecture: ${ARCH}" >&2
        exit 1
        ;;
esac

echo "=== Dotfiles CLI Tool Updater (Linux: ${ARCH}) ==="

# Helper to fetch latest GitHub release tag
get_latest_github_tag() {
    local repo="$1"
    curl -sSfL "https://api.github.com/repos/${repo}/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}

# 1. Neovim (AppImage or tarball)
echo "--> Updating Neovim..."
NVIM_TAG=$(get_latest_github_tag "neovim/neovim")
NVIM_URL="https://github.com/neovim/neovim/releases/download/${NVIM_TAG}/nvim-${NVIM_ARCH}.tar.gz"
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "${TEMP_DIR}"' EXIT

curl -sSfL "${NVIM_URL}" -o "${TEMP_DIR}/nvim.tar.gz"
tar -xzf "${TEMP_DIR}/nvim.tar.gz" -C "${TEMP_DIR}"
mkdir -p "${HOME}/.local/share/nvim-release"
rm -rf "${HOME}/.local/share/nvim-release/*"
cp -r "${TEMP_DIR}/nvim-${NVIM_ARCH}/"* "${HOME}/.local/share/nvim-release/"
ln -sf "${HOME}/.local/share/nvim-release/bin/nvim" "${BIN_DIR}/nvim"
echo "    Neovim updated to ${NVIM_TAG}"

# 2. Lazygit
echo "--> Updating Lazygit..."
LG_TAG=$(get_latest_github_tag "jesseduffield/lazygit")
LG_VER="${LG_TAG#v}"
LG_URL="https://github.com/jesseduffield/lazygit/releases/download/${LG_TAG}/lazygit_${LG_VER}_Linux_${LG_ARCH}.tar.gz"
curl -sSfL "${LG_URL}" -o "${TEMP_DIR}/lazygit.tar.gz"
tar -xzf "${TEMP_DIR}/lazygit.tar.gz" -C "${TEMP_DIR}" lazygit
mv "${TEMP_DIR}/lazygit" "${BIN_DIR}/lazygit"
chmod +x "${BIN_DIR}/lazygit"
echo "    Lazygit updated to ${LG_TAG}"

# 3. Ripgrep
echo "--> Updating Ripgrep..."
RG_TAG=$(get_latest_github_tag "BurntSushi/ripgrep")
RG_URL="https://github.com/BurntSushi/ripgrep/releases/download/${RG_TAG}/ripgrep-${RG_TAG}-${RG_ARCH}.tar.gz"
curl -sSfL "${RG_URL}" -o "${TEMP_DIR}/ripgrep.tar.gz"
tar -xzf "${TEMP_DIR}/ripgrep.tar.gz" -C "${TEMP_DIR}"
mv "${TEMP_DIR}/ripgrep-${RG_TAG}-${RG_ARCH}/rg" "${BIN_DIR}/rg"
chmod +x "${BIN_DIR}/rg"
echo "    Ripgrep updated to ${RG_TAG}"

# 4. Fd
echo "--> Updating Fd..."
FD_TAG=$(get_latest_github_tag "sharkdp/fd")
FD_URL="https://github.com/sharkdp/fd/releases/download/${FD_TAG}/fd-${FD_TAG}-${FD_ARCH}.tar.gz"
curl -sSfL "${FD_URL}" -o "${TEMP_DIR}/fd.tar.gz"
tar -xzf "${TEMP_DIR}/fd.tar.gz" -C "${TEMP_DIR}"
mv "${TEMP_DIR}/fd-${FD_TAG}-${FD_ARCH}/fd" "${BIN_DIR}/fd"
chmod +x "${BIN_DIR}/fd"
echo "    Fd updated to ${FD_TAG}"

# 5. Fzf
echo "--> Updating Fzf..."
FZF_TAG=$(get_latest_github_tag "junegunn/fzf")
FZF_VER="${FZF_TAG#v}"
FZF_URL="https://github.com/junegunn/fzf/releases/download/${FZF_TAG}/fzf-${FZF_VER}-${FZF_ARCH}.tar.gz"
curl -sSfL "${FZF_URL}" -o "${TEMP_DIR}/fzf.tar.gz"
tar -xzf "${TEMP_DIR}/fzf.tar.gz" -C "${TEMP_DIR}" fzf
mv "${TEMP_DIR}/fzf" "${BIN_DIR}/fzf"
chmod +x "${BIN_DIR}/fzf"
echo "    Fzf updated to ${FZF_TAG}"

# 6. Zoxide
echo "--> Updating Zoxide..."
curl -sSfo- https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

echo ""
echo "=== Current Versions ==="
for cmd in nvim lazygit rg fd fzf zoxide; do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo -n "$cmd: "
        "$cmd" --version 2>&1 | head -n 1
    else
        echo "$cmd: NOT FOUND"
    fi
done
