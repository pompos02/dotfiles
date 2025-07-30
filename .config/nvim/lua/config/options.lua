-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.snacks_animate = false

-- provided by rust-analyzer.
vim.g.lazyvim_rust_diagnostics = "rust-analyzer"
-- Disable visible tab characters that show as >
-- vim.opt.list = false
-- Or if you want to keep list mode but change the tab character:
-- vim.opt.listchars = { tab = "  ", trail = "-", nbsp = "+" }
