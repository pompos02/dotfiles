require("config.lazy")
require("config.options")
require("config.keymaps")
require("config.lsp")

vim.g.plsql_fold = 1

vim.opt.background = "dark"
vim.cmd.colorscheme("yara")


vim.o.winborder = "rounded"

vim.opt.expandtab = false   -- use tabs, not spaces
vim.opt.tabstop = 4         -- a tab displays as 4 columns
vim.opt.shiftwidth = 4      -- >> << and autoindent use 4
vim.opt.softtabstop = 4     -- <Tab>/<BS> behave as 4 columns

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking text",
    group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

vim.filetype.add({ extension = { pc = "cpp", } })
vim.filetype.add({
    extension = {
        pkb = "plsql",
        pks = "plsql",
        pls = "plsql",
        sql = "plsql",
    },
})

-- Use Windows explorer.exe for vim.ui.open (WSL/Windows friendly)
vim.ui.open = function(path)
    local job = vim.fn.jobstart({ "explorer.exe", path }, { detach = true })
    return job > 0
end

require 'colorizer'.setup()
