-- Common options for key mappings: no remapping and silent execution
local opts = { noremap = true, silent = true }

-- Sets the <Leader> and <LocalLeader> keys to space for convenience
vim.g.mapleader = " "
vim.g.maplocalleader = " "
-- Move selected lines down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "moves lines down in visual selection" })

-- Move selected lines up
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "moves lines up in visual selection" })

-- Center cursor after scrolling down
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "move down in buffer with cursor centered" })

-- Center cursor after scrolling up
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "move up in buffer with cursor centered" })

-- Center cursor and open folds when jumping to next search result
vim.keymap.set("n", "n", "nzzzv")

-- Same as above for previous search result
vim.keymap.set("n", "N", "Nzzzv")

-- Replace selected text without overwriting clipboard contents
vim.keymap.set("x", "<leader>p", [["_dP]])

-- Replace selected text without overwriting clipboard contents
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

--exit inster mode with cntrl+c
vim.keymap.set("i", "<C-c>", "<Esc>")
vim.keymap.set("i", "jj", "<Esc>")

-- In normal mode, clear search highlight with <Ctrl-c>
vim.keymap.set("n", "<C-c>", ":nohl<CR>", { desc = "Clear search hl", silent = true })

-- Format code using the LSP formatter
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

-- Highlight text after yanking (copied) for better visual feedback
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
    callback = function()
        vim.hl.on_yank()
    end,
})

-- Copy the relative file path of the current buffer to system clipboard
vim.keymap.set("n", "<leader>fp", function()
    local filePath = vim.fn.expand("%:~") -- Path relative to home directory
    vim.fn.setreg("+", filePath) -- Save to system clipboard
    print("File path copied to clipboard: " .. filePath)
end, { desc = "Copy file path to clipboard" })

-- Toggle visibility of LSP diagnostics (virtual text and underlines)
-- local isLspDiagnosticsVisible = true
-- vim.keymap.set("n", "<leader>lx", function()
--     isLspDiagnosticsVisible = not isLspDiagnosticsVisible
--     vim.diagnostic.config({
--         virtual_text = isLspDiagnosticsVisible,
--         underline = isLspDiagnosticsVisible
--     })
-- end, { desc = "Toggle LSP diagnostics" })
