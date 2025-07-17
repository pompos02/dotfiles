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
