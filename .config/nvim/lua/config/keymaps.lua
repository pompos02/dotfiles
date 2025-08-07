-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<C-c>", ":nohl<CR>", { desc = "Clear search hl", silent = true })
-- vim.keymap.set("n", "<leader>e", "<CMD>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "<leader>e", "<cmd>Oil --float<CR>", {
  desc = "Explorer (Oil)",
  noremap = true,   -- Prevents recursive mapping
  silent = true,    -- Suppresses messages
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

-- Go-specific keymaps
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    -- Insert error handling snippet with <C-e>
    vim.keymap.set("i", "<C-e>", function()
      local row, col = unpack(vim.api.nvim_win_get_cursor(0))

      -- Get current line to determine indentation
      local current_line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1] or ""
      local indent = current_line:match("^%s*") or ""

      -- Get tab/space settings
      local use_tabs = vim.bo.expandtab == false
      local tab_size = vim.bo.tabstop
      local inner_indent = use_tabs and (indent .. "\t") or (indent .. string.rep(" ", tab_size))

      local lines = {
        indent .. "if err != nil {",
        inner_indent,
        indent .. "}",
      }
      vim.api.nvim_buf_set_lines(0, row, row, false, lines)
      vim.api.nvim_win_set_cursor(0, { row + 2, #inner_indent + 1 })
      vim.cmd("startinsert!")
    end, {
      desc = "Insert Go error handling",
      buffer = true,
      silent = true,
    })
  end,
})
