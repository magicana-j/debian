-- lua/plugins/colorscheme.lua
return {
    {
        "projekt0n/github-nvim-theme",
        name = "github-theme",
        lazy = false,
        priority = 1000,
        config = function()
        require("github-theme").setup({
            options = {
                -- 非アクティブウィンドウを薄暗くして視認性向上
                dim_inactive = true,
                -- フローティングウィンドウの背景を暗く
                darken = {
                    floats = true,
                    sidebars = { enable = true, list = { "neo-tree", "qf" } },
                },
                -- モジュール別ハイライト（git系を明示的に有効化）
                modules = {
                    gitsigns   = true,
                    neogit     = true,
                    neotree    = true,
                    telescope  = true,
                    diffchar   = true,
                    native_lsp = { enable = true, background = true },
                    diagnostic = { enable = true, background = true },
                },
            },
        })
        -- CUD対応テーマを適用
        -- "github_dark_colorblind" | "github_light_colorblind"
        -- "github_dark_tritanopia" | "github_light_tritanopia"
        -- "github_dark_high_contrast" | "github_light_high_contrast"
        vim.cmd("colorscheme github_dark_colorblind")
        end,
    },
}
