require("config.lazy")
require("config.options")
require("config.keymaps")
require("config.lsp")

-- custom plugins
require("custom.statusline").setup()
require("custom.surround").setup()

vim.opt.shiftwidth = 4
vim.o.winborder = "rounded"

-- Set the colorscheme
vim.cmd.colorscheme("misirlou-lb")


-- highlight when yanking
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking text",
    group = vim.api.nvim_create_augroup("highlight yank", { clear = true }),
    callback = function()
        vim.hl.on_yank({ higroup = "YankHighlight", timeout = 150 })
    end,
})
