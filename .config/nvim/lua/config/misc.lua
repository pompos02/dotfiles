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
