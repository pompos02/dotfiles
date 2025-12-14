if vim.g.loaded_fzf_lua == 1 then return end
vim.g.loaded_fzf_lua = 1

if vim.fn.has("nvim-0.9") ~= 1 then
  vim.notify("Fzf-lua requires neovim >= v0.9", vim.log.levels.ERROR, { title = "fzf-lua" })
  return
end

vim.api.nvim_create_user_command("FzfLua", function(opts)
  ---@diagnostic disable-next-line: param-type-mismatch
  require("fzf-lua.cmd").run_command(unpack(opts.fargs))
end, {
  nargs = "*",
  range = true,
  complete = function(_, line)
    return require("fzf-lua.cmd")._candidates(line)
  end,
})
