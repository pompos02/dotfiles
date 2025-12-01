-- Minimal Neovim configuration without plugin managers
-- Plugins are loaded from pack/vendor/start/ (Vim's native plugin system)

-- Set leader keys FIRST before any mappings
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Disable fzf history; we don't want per-command files created
vim.g.fzf_history_dir = ""

-- Load core configuration modules
require("config.options")
require("config.keymaps")
require("config.lsp")

-- Load custom plugins (pure Lua, no external dependencies)
require("custom.statusline").setup()
require("custom.surround").setup()


-- Set shiftwidth and window borders
vim.opt.shiftwidth = 4
vim.o.winborder = "rounded"

-- Set colorscheme
-- vim.cmd.colorscheme("misirlou-lightstrong")
vim.cmd.colorscheme("misirlou-lb")

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking text",
    group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})
