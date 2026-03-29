#!/usr/bin/env bash
# =============================================================================
# setup_virtualbox_postinstall.sh
# VirtualBox インストール後のセットアップスクリプト
#
# 処理内容:
#   1. 依存パッケージのインストール (dkms, linux-headers)
#   2. KVM モジュールのアンロード (systemd / openrc / runit 問わず)
#   3. VirtualBox カーネルモジュールのビルド & ロード
#   4. Extension Pack のダウンロード & インストール
#   5. vboxusers グループへの追加
# =============================================================================
set -euo pipefail

info()    { echo -e "\e[34m[INFO]\e[0m  $*"; }
success() { echo -e "\e[32m[OK]\e[0m    $*"; }
warn()    { echo -e "\e[33m[WARN]\e[0m  $*"; }
error()   { echo -e "\e[31m[ERROR]\e[0m $*" >&2; exit 1; }

[[ $EUID -eq 0 ]] || error "sudo で実行してください。例: sudo bash $0"

REAL_USER="${SUDO_USER:-$(logname 2>/dev/null || echo '')}"
[[ -n "$REAL_USER" ]] || error "実行ユーザーを特定できませんでした。"

command -v VBoxManage &>/dev/null \
    || error "VBoxManage が見つかりません。先に VirtualBox 本体をインストールしてください。"

VB_VERSION=$(VBoxManage --version | grep -oP '^\d+\.\d+\.\d+')
info "検出した VirtualBox バージョン: $VB_VERSION"

# =============================================================================
# ユーティリティ: init システム判定
# =============================================================================
detect_init() {
    if [[ "$(cat /proc/1/comm 2>/dev/null)" == "systemd" ]]; then
        echo "systemd"
    elif [[ -x /sbin/openrc ]] || [[ -x /usr/sbin/openrc ]]; then
        echo "openrc"
    elif [[ -d /etc/runit ]] && command -v sv &>/dev/null; then
        echo "runit"
    elif [[ -d /etc/s6 ]] || command -v s6-rc &>/dev/null; then
        echo "s6"
    else
        echo "sysvinit"
    fi
}

INIT_SYSTEM=$(detect_init)
info "検出した init システム: $INIT_SYSTEM"

# =============================================================================
# ユーティリティ: サービス停止 (init 非依存)
# サービスが存在しない・停止済みでもエラーにしない
# =============================================================================
stop_service() {
    local svc="$1"
    case "$INIT_SYSTEM" in
        systemd)
            if systemctl is-active --quiet "$svc" 2>/dev/null; then
                systemctl stop "$svc" && info "停止: $svc (systemd)"
            fi
            ;;
        openrc)
            if rc-service "$svc" status &>/dev/null; then
                rc-service "$svc" stop 2>/dev/null && info "停止: $svc (openrc)"
            fi
            ;;
        runit)
            if sv status "$svc" &>/dev/null; then
                sv stop "$svc" 2>/dev/null && info "停止: $svc (runit)"
            fi
            ;;
        s6)
            s6-rc -d change "$svc" 2>/dev/null && info "停止: $svc (s6)" || true
            ;;
        sysvinit|*)
            if service "$svc" status &>/dev/null; then
                service "$svc" stop 2>/dev/null && info "停止: $svc (sysvinit)"
            fi
            ;;
    esac
}

# =============================================================================
# ユーティリティ: モジュールアンロード (使用中・未ロードでもエラーにしない)
# =============================================================================
unload_module() {
    local mod="$1"
    if lsmod | grep -q "^${mod}\s"; then
        if modprobe -r "$mod" 2>/dev/null; then
            info "アンロード: $mod"
        else
            warn "アンロード失敗: $mod (使用中の可能性があります)"
        fi
    fi
}

# =============================================================================
# 1. 依存パッケージのインストール
# =============================================================================
info "依存パッケージをインストールします..."
apt-get update -qq
apt-get install -y --no-install-recommends \
    dkms \
    linux-headers-"$(uname -r)"
success "依存パッケージのインストール完了"

# =============================================================================
# 2. KVM の停止とモジュールアンロード
# =============================================================================
info "KVM 関連サービスを停止します..."
for svc in libvirtd virtqemud libvirt-guests; do
    stop_service "$svc"
done

info "KVM カーネルモジュールをアンロードします..."
unload_module kvm_intel
unload_module kvm_amd
unload_module kvm
success "KVM のアンロード処理完了"

# =============================================================================
# 3. VirtualBox カーネルモジュールのビルド & ロード
# =============================================================================
info "VirtualBox カーネルモジュールをビルドします..."
/sbin/vboxconfig \
    && success "カーネルモジュールのビルド完了" \
    || error "vboxconfig が失敗しました。上記のエラーメッセージを確認してください。"

info "VirtualBox カーネルモジュールをロードします..."
for mod in vboxdrv vboxnetflt vboxnetadp; do
    if modprobe "$mod" 2>/dev/null; then
        info "ロード: $mod"
    else
        warn "ロード失敗: $mod"
    fi
done
success "モジュールのロード完了"

# =============================================================================
# 4. Extension Pack のダウンロード & インストール
# =============================================================================
EXTPACK_FILENAME="Oracle_VirtualBox_Extension_Pack-${VB_VERSION}.vbox-extpack"
EXTPACK_URL="https://download.virtualbox.org/virtualbox/${VB_VERSION}/${EXTPACK_FILENAME}"
EXTPACK_PATH="/tmp/${EXTPACK_FILENAME}"

info "Extension Pack をダウンロードします..."
curl -fSL --progress-bar -o "$EXTPACK_PATH" "$EXTPACK_URL" \
    || error "ダウンロードに失敗しました。URL: $EXTPACK_URL"

info "Extension Pack をインストールします..."
echo "y" | VBoxManage extpack install --replace "$EXTPACK_PATH"
rm -f "$EXTPACK_PATH"

VBoxManage list extpacks | grep -q "Oracle VirtualBox Extension Pack" \
    && success "Extension Pack のインストール確認 OK" \
    || warn "Extension Pack の確認ができませんでした。VBoxManage list extpacks で確認してください。"

# =============================================================================
# 5. vboxusers グループへの追加
# =============================================================================
if id -nG "$REAL_USER" | grep -qw "vboxusers"; then
    info "$REAL_USER はすでに vboxusers グループに所属しています。"
else
    usermod -aG vboxusers "$REAL_USER"
    success "$REAL_USER を vboxusers グループに追加しました。"
fi

# =============================================================================
# 完了
# =============================================================================
echo ""
success "セットアップ完了。"
echo ""
echo "注意事項:"
echo "  - vboxusers グループの反映には再ログインが必要です。"
echo "  - カーネル更新後は sudo /sbin/vboxconfig の再実行が必要です。"
echo "  - KVM を再度使うには: sudo modprobe kvm && sudo modprobe kvm_intel (または kvm_amd)"
echo ""
