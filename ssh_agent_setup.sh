#!/bin/bash

# 1. SSHキーの確認と生成
if [ ! -f ~/.ssh/id_ed25519 ]; then
    echo "SSHキーが見つかりません。新しいキー（Ed25519）を生成します。"
    ssh-keygen -t ed25519 -C "$(git config user.email)" -N "" -f ~/.ssh/id_ed25519
fi

# 2. SSH Agentの起動とキーの登録
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# 3. GitHubへの公開鍵の表示
echo "-------------------------------------------------------"
echo "以下の公開鍵をコピーして、GitHubの 'SSH and GPG keys' に登録してください。"
echo "URL: https://github.com/settings/keys"
echo "-------------------------------------------------------"
cat ~/.ssh/id_ed25519.pub
echo "-------------------------------------------------------"
read -p "GitHubへの登録が完了したらEnterを押してください..."

# 4. 接続テスト
echo "GitHubへの接続テストを実施します..."
ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"
if [ $? -eq 0 ]; then
    echo "GitHubとの認証に成功しました。"
else
    echo "認証に失敗しました。公開鍵が正しく登録されているか確認してください。"
    exit 1
fi

# 5. リモートURLをHTTPSからSSHに変更
if [ -d .git ]; then
    CURRENT_URL=$(git remote get-url origin)
    if [[ $CURRENT_URL == https://github.com/* ]]; then
        NEW_URL=${CURRENT_URL/https:\/\/github.com\//git@github.com:}
        git remote set-url origin "$NEW_URL"
        echo "リモートURLを SSH に変更しました: $NEW_URL"
    else
        echo "現在のURLはすでにSSH形式か、GitHubのリポジトリではありません。"
    fi
else
    echo "現在のディレクトリはGitリポジトリではありません。"
fi
