-- lua/plugins/files.lua
return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        cmd = "Neotree",
        keys = {
            { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Explorer NeoTree" },
            { "<leader>E", "<cmd>Neotree reveal<cr>", desc = "Reveal in NeoTree" },
        },
        opts = {
            sources = { "filesystem", "buffers", "git_status" },
            filesystem = {
                filtered_items = {
                    hide_dotfiles = false,  -- dotfileを表示
                    hide_gitignored = false,
                },
                follow_current_file = { enabled = true },
                use_libuv_file_watcher = true, -- ファイル変更を自動検出
            },
            window = {
                width = 35,
                mappings = {
                    ["<space>"] = "none",
                    ["Y"] = {
                        function(state)
                        local node = state.tree:get_node()
                        vim.fn.setreg("+", node.path)
                        end,
                        desc = "Copy path to clipboard",
                    },
                },
            },
        },
    },

}
