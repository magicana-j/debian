-- 基本設定
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.opt.termguicolors = true      -- True color 対応
vim.opt.syntax = "on"
vim.opt.mouse = "a"               -- マウス操作を有効化
vim.opt.clipboard = "unnamedplus" -- システムのクリップボードと共有

-- 表示設定
vim.opt.number = true             -- 行番号表示
vim.opt.relativenumber = true     -- 相対行番号表示
vim.opt.cursorline = true         -- 現在行をハイライト
vim.opt.wrap = true               -- 行の折り返しを有効
vim.opt.linebreak = true          -- 単語単位で折り返す
vim.opt.showcmd = true            -- コマンドをステータスに表示
vim.opt.showmode = false          -- モード表示は無効（ステータスライン使用前提）

-- インデント設定
vim.opt.expandtab = true          -- タブをスペースに変換
vim.opt.shiftwidth = 4            -- インデント幅
vim.opt.tabstop = 4               -- タブ幅
vim.opt.softtabstop = 4           -- タブキーの幅
vim.opt.autoindent = true         -- 自動インデント
vim.opt.smartindent = true        -- Cスタイル自動インデント

-- 検索設定
vim.opt.ignorecase = true         -- 大文字小文字を無視
vim.opt.smartcase = true          -- 大文字が含まれていれば区別
vim.opt.incsearch = true          -- インクリメンタルサーチ
vim.opt.hlsearch = true           -- 検索結果をハイライト

-- バックアップ無効化（必要であれば有効に）
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false

-- スクロール設定
vim.opt.scrolloff = 4             -- 上下に常に余白を確保
vim.opt.sidescrolloff = 4

-- エンコーディング自動検出（日本語向け）
vim.opt.fileencodings = { "utf-8", "cp932", "euc-jp", "iso-2022-jp" }

-- 行末スペースの自動削除（保存時）
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
        local pos = vim.api.nvim_win_get_cursor(0)
        vim.cmd([[%s/\s\+$//e]])
        vim.api.nvim_win_set_cursor(0, pos)
    end,
})

-- カラースキーム（組み込み）
vim.cmd("colorscheme industry") -- 他に "elflord", "evening", "morning", "industry" なども可
