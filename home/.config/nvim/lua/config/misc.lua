-------------------------------------------------------
-- Disable `show list` in filtypes
-------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"compilation"},
  callback = function()
    vim.opt_local.list = false
  end,
})
