local map = vim.keymap.set

-- clear search highlight
map("n", "<C-c>", ":nohl<CR>", { desc = "Clear search hl", silent = true })
map("n", "<Esc>", function()
    if vim.opt.hlsearch:get() then
        vim.cmd.nohlsearch()
    else
        return "<Esc>"
    end
end, { desc = "Clear search hl", silent = true, expr = true })

-- jump to next/prev snippet
map({ "i", "s" }, "<c-l>", function()
    if vim.snippet.active({ direction = 1 }) then
        vim.snippet.jump(1)
        return
   end
    return "<Tab>"
end, { silent = true, expr = true })
map({ "i", "s" }, "<c-h>", function()
    if vim.snippet.active({ direction = -1 }) then
        vim.snippet.jump(-1)
        return
    end
    return "<S-Tab>"
end, { silent = true, expr = true })

-- moving lines up and down
map("v", "K", ":m '<-2<CR>gv=gv")
map("v", "J", ":m '>+1<CR>gv=gv")
-- delete but not yank
map({ "n", "v" }, "<leader>d", [["_d]])
-- Paste without overwriting the default register
map("v", "<Leader>p", '"_dP')

-- horizontall movements
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down and center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up and center" })
map("n", "}", "}zz", { desc = "Next paragraph and center" })
map("n", "{", "{zz", { desc = "Previous paragraph and center" })
-- better up/down
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", {
    desc = "Down",
    expr = true,
    silent = true,
})

map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", {
    desc = "Down",
    expr = true,
    silent = true,
})
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", {
    desc = "Up",
    expr = true,
    silent = true,
})
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", {
    desc = "Up",
    expr = true,
    silent = true,
})

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

-- Diagnostics and Quickfix
map("n", "<leader>xx", function()
    vim.diagnostic.setqflist()
    vim.cmd.copen()
end, { desc = "Open diagnostics in quickfix" })

-- Quickfix navigation
map("n", "[q", function()
    local ok, err = pcall(vim.cmd.cprev)
    if not ok then
        vim.notify(err, vim.log.levels.ERROR)
    end
end, { desc = "Previous quickfix item" })

map("n", "]q", function()
    local ok, err = pcall(vim.cmd.cnext)
    if not ok then
        vim.notify(err, vim.log.levels.ERROR)
    end
end, { desc = "Next quickfix item" })
