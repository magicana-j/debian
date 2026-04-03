#!/bin/bash

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: This script must be run as root or with sudo."
    exit 1
fi

# OpenJDK 25のインストールを確認
if ! command -v java &> /dev/null; then
    echo "OpenJDKがインストールされていません。OpenJDK 25をインストールします。"

    # Debianのパッケージリストを更新
    sudo apt-get update

    # OpenJDK 25のインストール
    sudo apt-get install -y openjdk-25-jdk

    # インストール結果を確認
    if command -v java &> /dev/null; then
        echo "OpenJDK 25のインストールが完了しました。"
        java -version
    else
        echo "OpenJDK 25のインストールに失敗しました。"
    fi
else
    echo "OpenJDKは既にインストールされています。"
    java -version
fi

