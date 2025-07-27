-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<C-c>", ":nohl<CR>", { desc = "Clear search hl", silent = true })
-- vim.keymap.set("n", "<leader>e", "<CMD>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "<leader>e", "<cmd>Oil --float<CR>", {
    desc = "Explorer (Oil)",
    noremap = true, -- Prevents recursive mapping
    silent = true, -- Suppresses messages
})

vim.keymap.set("n", "<leader>E", function()
    require("oil").open_float(vim.fn.getcwd())
end, {
    desc = "Explorer (Oil) - Project Root",
    noremap = true,
    silent = true,
})

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
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '>-2<CR>gv=gv")
-- delete but not yank
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])
