require("config.lazy")
require("config.options")
require("config.keymaps")
require("config.lsp")

vim.g.plsql_fold = 1

vim.opt.background = "dark"
vim.cmd.colorscheme("yara-grey")


vim.o.winborder = "single"

vim.opt.expandtab = true
vim.opt.tabstop = 4      -- a tab displays as 4 columns
vim.opt.shiftwidth = 4   -- >> << and autoindent use 4
vim.opt.softtabstop = 4  -- <Tab>/<BS> behave as 4 columns

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking text",
    group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Open the quickfix window automatically after commands that populate it.
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
    desc = "Open quickfix when populated",
    group = vim.api.nvim_create_augroup("quickfix_open", { clear = true }),
    pattern = { "make", "grep", "vimgrep" },
    command = "cwindow",
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

-- Use explorer.exe in WSL, otherwise xdg-open
local is_wsl = vim.env.WSL_DISTRO_NAME ~= nil
vim.ui.open = function(path)
    local cmd = is_wsl and "explorer.exe" or "xdg-open"
    return vim.fn.jobstart({ cmd, path }, { detach = true }) > 0
end
