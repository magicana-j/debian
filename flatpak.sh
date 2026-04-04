#!/bin/bash

# スクリプトを中断した際にエラーで終了するように設定
set -e

echo "Debian用のFlatpakセットアップを開始します..."

# 1. パッケージリストを更新
sudo apt-get update

# 2. Flatpak本体をインストール
# GNOME環境を使用している場合は gnome-software-plugin-flatpak も追加でインストールすると便利です
echo "Flatpakをインストール中..."
sudo apt-get install -y flatpak

# 3. Flathubリポジトリを追加
echo "Flathubリポジトリを登録中..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

echo "----------------------------------------------------"
echo "セットアップが完了しました。"
echo "設定を反映させるために、システムを再起動するか一度ログアウトしてください。"
echo "----------------------------------------------------"

