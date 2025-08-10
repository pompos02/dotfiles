require("config.lazy")
require("config.options")
require("config.keymaps")
vim.cmd.colorscheme("rose-pine-moon")
vim.keymap.set("n", "<space>x", ":.lua<cr>")
vim.keymap.set("v", "<space>x", ":.lua<cr>")

vim.opt.shiftwidth = 4

-- highlight when yanking
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking text",
    group = vim.api.nvim_create_augroup("highlight yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})
