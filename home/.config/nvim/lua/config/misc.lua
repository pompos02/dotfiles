-------------------------------------------------------
-- Remove TODO user commands
-------------------------------------------------------
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy", -- Wait until plugins load before deleting commands
  callback = function()
    local commands = { "TodoFzfLua", "TodoLocList", "TodoQuickFix", "TodoTelescope", "TodoTrouble" }
    for _, cmd in ipairs(commands) do
      if vim.fn.exists(":" .. cmd) == 2 then
        vim.api.nvim_del_user_command(cmd)
      end
    end
  end,
})

-------------------------------------------------------
-- Disable `show list` in filtypes
-------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"compilation"},
  callback = function()
    vim.opt_local.list = false
  end,
})

