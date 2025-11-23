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

-- Add undo break-points
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")
-- better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- foramatting
map("n", "<leader>lf", vim.lsp.buf.format, { desc = "Format the current buffer" })

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

-- Custom picker (pure Lua, no dependencies)
map("n", "<leader><leader>", function() require("custom.picker").find_files() end, { desc = "Find files" })
map("n", "<leader>fg", function() require("custom.picker").live_grep() end, { desc = "Live grep" })
map("n", "<leader>fb", function() require("custom.picker").buffers() end, { desc = "Switch buffer" })
map("n", "<leader>fh", function() require("custom.picker").help_tags() end, { desc = "Help tags" })
map("n", "<leader>fo", function() require("custom.picker").oldfiles() end, { desc = "Recent files" })
map("n", "<leader>fk", function() require("custom.picker").keymaps() end, { desc = "Find keymaps" })


-- Native LSP navigation
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
map("n", "gr", vim.lsp.buf.references, { desc = "Show references" })
map("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
map("n", "<leader>lr", vim.lsp.buf.references, { desc = "References" })
map("n", "<leader>ls", vim.lsp.buf.document_symbol, { desc = "Document symbols" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Actions" })

-- Resize window using <ctrl> arrow keys
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- File explorer (native netrw)
map("n", "<leader>e", ":Explore<CR>", { desc = "Explorer (netrw)" })
map("n", "<leader>E", ":Explore " .. vim.fn.getcwd() .. "<CR>", { desc = "Explorer - Project Root" })

-- Vimgrep visual selection (populate command, don't execute)
map("v", "gs", function()
    vim.cmd('noau normal! "vy"')
    local text = vim.fn.getreg('v')
    -- Escape forward slashes for vimgrep pattern
    text = text:gsub("/", "\\/")
    vim.fn.feedkeys(":vimgrep /" .. text .. "/j **/*", 'n')
end, { desc = "Vimgrep selection in codebase" })

-- Vimgrep word under cursor (normal mode)
map("n", "gw", function()
    local word = vim.fn.expand("<cword>")
    word = word:gsub("/", "\\/")
    vim.fn.feedkeys(":vimgrep /" .. word .. "/j **/*", 'n')
end, { desc = "Vimgrep word under cursor" })
