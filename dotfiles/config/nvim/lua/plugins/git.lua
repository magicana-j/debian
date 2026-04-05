-- lua/plugins/git.lua
return {
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            signs = {
                add          = { text = "▎" },
                change       = { text = "▎" },
                delete       = { text = "" },
                topdelete    = { text = "" },
                changedelete = { text = "▎" },
                untracked    = { text = "▎" },
            },
            -- カレント行のblameをvirtual textで表示
            current_line_blame = true,
            current_line_blame_opts = {
                delay = 500,
                virt_text_pos = "eol",
            },
            on_attach = function(buffer)
            local gs = package.loaded.gitsigns
            local map = function(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
            end
            -- ハンクナビゲーション
            map("n", "]h", gs.next_hunk, "Next Hunk")
            map("n", "[h", gs.prev_hunk, "Prev Hunk")
            -- ステージング操作
            map({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
            map({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
            map("n", "<leader>hS", gs.stage_buffer, "Stage Buffer")
            map("n", "<leader>hu", gs.undo_stage_hunk, "Undo Stage Hunk")
            map("n", "<leader>hR", gs.reset_buffer, "Reset Buffer")
            map("n", "<leader>hp", gs.preview_hunk_inline, "Preview Hunk Inline")
            map("n", "<leader>hb", gs.blame_line, "Blame Line")
            map("n", "<leader>hd", gs.diffthis, "Diff This")
            end,
        },
    },

    {
        "sindrets/diffview.nvim",
        cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
        keys = {
            { "<leader>gd", "<cmd>DiffviewOpen<cr>",        desc = "DiffView Open" },
            { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File History" },
            { "<leader>gD", "<cmd>DiffviewClose<cr>",       desc = "DiffView Close" },
        },
        opts = {
            enhanced_diff_hl = true, -- 行内の変更点をハイライト
            view = {
                merge_tool = {
                    layout = "diff3_mixed", -- 3ペインマージビュー
                    disable_diagnostics = true,
                },
            },
        },
    },

    {
        "NeogitOrg/neogit",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "sindrets/diffview.nvim", -- 後述と連携
        },
        cmd = "Neogit",
        keys = {
            { "<leader>gg", "<cmd>Neogit<cr>", desc = "Neogit" },
        },
        opts = {
            graph_style = "unicode", -- ブランチグラフをunicodeで綺麗に表示
            integrations = {
                diffview = true,  -- diffview.nvimと連携
            },
            signs = {
                hunk    = { "", "" },
                item    = { "›", "⌄" },
                section = { "›", "⌄" },
            },
        },
    },
}
