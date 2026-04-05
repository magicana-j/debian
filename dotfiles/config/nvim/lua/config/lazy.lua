-- lua/config/lazy.lua - lazy.nvimのブートストラップと設定

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- pluginsディレクトリ内のすべてのプラグイン設定を読み込み
    { import = "plugins" },
  },
  defaults = {
    lazy = false, -- プラグインをデフォルトで遅延読み込みしない
  },
  checker = { 
    enabled = true,  -- プラグインの更新を自動チェック
    frequency = 3600, -- 1時間ごと
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
