require("config.lazy")
require("config.options")
require("config.keymaps")
vim.opt.shiftwidth = 4
vim.o.winborder = "rounded"

-- highlight when yanking

-- Set the colorscheme
vim.cmd.colorscheme("misirloun")
require("config.statusline").setup()
-- vim.cmd.colorscheme("lackluster")
-- vim.cmd.colorscheme("vague")
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking text",
    group = vim.api.nvim_create_augroup("highlight yank", { clear = true }),
    callback = function()
        vim.hl.on_yank({ higroup = "YankHighlight", timeout = 150 })
    end,
})
