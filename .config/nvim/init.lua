-- bootstrap lazy.nvim, LazyVim and your plugins

--- Set leaders before loading lazy
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.lazy")
