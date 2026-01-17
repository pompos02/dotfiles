-- Save and reset 'cpoptions'
local cpo_save = vim.o.cpoptions
vim.cmd('set cpo&vim')

-- Conditional folding
if vim.g.plsql_fold == 1 then
  vim.opt_local.foldmethod = 'syntax'
  vim.b.undo_ftplugin = 'setlocal foldmethod<'
end

-- Use SQL line comments by default
vim.opt_local.commentstring = "-- %s"

-- Restore 'cpoptions'
vim.o.cpoptions = cpo_save

local undo = vim.b.undo_ftplugin or ""
if undo ~= "" then
  undo = undo .. " | "
end
vim.b.undo_ftplugin = undo .. "setlocal omnifunc< | setlocal commentstring<"
