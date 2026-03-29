#!/bin/bash
# Debian 13 (trixie) - Haskell 開発環境の前提パッケージインストールスクリプト
# GHCup によるツールチェーン導入を前提とした構成

set -euo pipefail

REQUIRED_PACKAGES=(
    # ビルドツール
    build-essential
    pkg-config
    make
    # GHC / GHCup が必要とするランタイムライブラリ
    libffi-dev
    libgmp-dev
    libgmp10
    libncurses-dev
    libtinfo-dev
    zlib1g-dev
    # ダウンロードツール（GHCup インストーラーの実行に必要）
    curl
    # SSL 証明書（curl の HTTPS 通信に必要）
    ca-certificates
    # GHCup / Stack が内部で使用
    git
)

echo "=== Haskell 前提パッケージのインストール ==="
echo "対象パッケージ: ${REQUIRED_PACKAGES[*]}"
echo ""

if [[ $EUID -ne 0 ]]; then
    SUDO=sudo
else
    SUDO=""
fi

$SUDO apt-get update
$SUDO apt-get install -y "${REQUIRED_PACKAGES[@]}"

echo ""
echo "=== インストール完了 ==="
echo "次のステップ: GHCup で GHC / Cabal / Stack / HLS をインストールしてください。"
echo "  curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh"
