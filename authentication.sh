#!/bin/bash

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run this script with sudo or as root."
  exit 1
fi

# Chromeの依存ライブラリと通信に必要なパッケージのインストール
#
# bluez: Bluetooth通信用 (パスキー等で使用)
# libnss3: セキュリティプロトコル用
# dbus-x11: アプリケーション間の通信用
#
# インストール済みの場合は自動的にスキップされます
sudo apt-get update
sudo apt-get install -y libnss3 bluez dbus-x11

# 起動時の自動実行設定
sudo update-rc.d dbus defaults
sudo update-rc.d bluetooth defaults

# サービスの状態を確認して起動する関数
manage_service() {
    local SERVICE_NAME=$1

    # service status コマンドの戻り値で状態を判定
    # 0 は実行中、それ以外は停止中とみなします
    if sudo service "$SERVICE_NAME" status > /dev/null 2>&1; then
        echo "通知: $SERVICE_NAME は既に起動しています。処理をスキップします。"
    else
        echo "通知: $SERVICE_NAME が停止しているため、起動を開始します..."
        sudo service "$SERVICE_NAME" start
    fi
}

# 各サービスのチェックと実行
manage_service dbus
manage_service bluetooth

echo "完了しました。Google Chromeを再起動してください。"
