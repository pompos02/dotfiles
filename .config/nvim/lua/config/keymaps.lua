-- clear search highlight
vim.keymap.set("n", "<C-c>", ":nohl<CR>", { desc = "Clear search hl", silent = true })
vim.keymap.set("n", "<Esc>", function()
    if vim.opt.hlsearch:get() then
        vim.cmd.nohlsearch()
    else
        return "<Esc>"
    end
end, { desc = "Clear search hl", silent = true, expr = true })

-- jump to next/prev snippet
vim.keymap.set({ "i", "s" }, "<c-l>", function()
    if vim.snippet.active({ direction = 1 }) then
        vim.snippet.jump(1)
        return
    end
    return "<Tab>"
end, { silent = true, expr = true })

vim.keymap.set({ "i", "s" }, "<c-h>", function()
    if vim.snippet.active({ direction = -1 }) then
        vim.snippet.jump(-1)
        return
    end
    return "<S-Tab>"
end, { silent = true, expr = true })

-- moving lines up and down
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
-- delete but not yank
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

local map = vim.keymap.set

-- horizontall movements
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down and center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up and center" })
map("n", "}", "}zz", { desc = "Next paragraph and center" })
map("n", "{", "{zz", { desc = "Previous paragraph and center" })
-- better up/down
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- Move to window using the <ctrl> hjkl keys
map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

-- Window splits
map("n", "<leader>wv", "<C-w>v", { desc = "Split Window Vertically" })
map("n", "<leader>wh", "<C-w>s", { desc = "Split Window Horizontally" })

-- Buffer management
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete Buffer" })

-- Resize window using <ctrl> arrow keys
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Add undo break-points
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")
-- better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- foramatting
map("n", "<leader>lf", vim.lsp.buf.format, { desc = "Format the current buffer" })

-- actions
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Actions" })
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename variable" })
