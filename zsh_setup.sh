#!/bin/bash
# setup_zsh.sh
# deb系Linux向け: zshインストール → oh-my-zsh導入 → ログインシェル設定

set -euo pipefail

# ── 定数 ────────────────────────────────────────────────────────────────
OHMYZSH_INSTALL_URL="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME=$(eval echo "~${TARGET_USER}")

# ── ヘルパー ─────────────────────────────────────────────────────────────
info()  { echo "[INFO]  $*"; }
warn()  { echo "[WARN]  $*" >&2; }
abort() { echo "[ERROR] $*" >&2; exit 1; }

need_root() {
    [[ $EUID -eq 0 ]] || abort "このスクリプトは sudo で実行してください。例: sudo bash $0"
}

# ── 1. zsh インストール ───────────────────────────────────────────────────
install_zsh() {
    info "パッケージリストを更新しています..."
    apt-get update -qq

    if command -v zsh &>/dev/null; then
        info "zsh はすでにインストール済みです: $(zsh --version)"
    else
        info "zsh をインストールしています..."
        apt-get install -y zsh
        info "インストール完了: $(zsh --version)"
    fi
}

# ── 2. oh-my-zsh インストール ────────────────────────────────────────────
install_ohmyzsh() {
    local omz_dir="${TARGET_HOME}/.oh-my-zsh"

    if [[ -d "$omz_dir" ]]; then
        info "oh-my-zsh はすでに存在します: $omz_dir"
        return
    fi

    info "oh-my-zsh をインストールしています (ユーザー: ${TARGET_USER})..."

    # curl / wget どちらかで取得
    local installer
    installer=$(mktemp /tmp/ohmyzsh_install.XXXXXX.sh)

    if command -v curl &>/dev/null; then
        curl -fsSL "$OHMYZSH_INSTALL_URL" -o "$installer"
    elif command -v wget &>/dev/null; then
        wget -qO "$installer" "$OHMYZSH_INSTALL_URL"
    else
        abort "curl または wget が必要です。apt-get install curl でインストールしてください。"
    fi

    # RUNZSH=no  : インストール後に自動でzsh起動しない
    # CHSH=no    : ログインシェル変更はこのスクリプトで後から行う
    sudo -u "$TARGET_USER" \
        RUNZSH=no CHSH=no \
        sh "$installer" --unattended

    rm -f "$installer"
    info "oh-my-zsh のインストール完了: $omz_dir"
}

# ── 3. ログインシェルを zsh に変更 ────────────────────────────────────────
set_login_shell() {
    local zsh_path
    zsh_path=$(command -v zsh)

    # /etc/shells に登録されているか確認
    if ! grep -qxF "$zsh_path" /etc/shells; then
        info "$zsh_path を /etc/shells に追加します..."
        echo "$zsh_path" >> /etc/shells
    fi

    local current_shell
    current_shell=$(getent passwd "$TARGET_USER" | cut -d: -f7)

    if [[ "$current_shell" == "$zsh_path" ]]; then
        info "ログインシェルはすでに zsh です: $zsh_path"
    else
        info "ログインシェルを変更しています: $current_shell → $zsh_path"
        chsh -s "$zsh_path" "$TARGET_USER"
        info "変更完了。次回ログイン時から zsh が起動します。"
    fi
}

# ── 4. .zshrc の確認 ─────────────────────────────────────────────────────
check_zshrc() {
    local zshrc="${TARGET_HOME}/.zshrc"
    if [[ -f "$zshrc" ]]; then
        info ".zshrc が存在します: $zshrc"
    else
        warn ".zshrc が見つかりません。oh-my-zsh のインストールに問題があった可能性があります。"
    fi
}

# ── メイン ───────────────────────────────────────────────────────────────
main() {
    need_root
    info "=== セットアップ開始 (対象ユーザー: ${TARGET_USER}) ==="
    install_zsh
    install_ohmyzsh
    set_login_shell
    check_zshrc
    info "=== セットアップ完了 ==="
    echo ""
    echo "  再ログインするか、以下を実行してシェルを切り替えてください:"
    echo "    exec zsh"
}

main "$@"
