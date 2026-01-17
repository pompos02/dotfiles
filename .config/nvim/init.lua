require("config.lazy")
require("config.options")
require("config.keymaps")
require("config.lsp")

vim.cmd("colorscheme vague")
vim.opt.shiftwidth = 4
vim.o.winborder = "rounded"


vim.cmd.colorscheme("solarized-osaka")
vim.opt.background = "dark"

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking text",
    group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

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
