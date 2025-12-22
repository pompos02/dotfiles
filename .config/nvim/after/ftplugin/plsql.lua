-- Prevent loading twice
if vim.b.did_ftplugin then
  return
end
vim.b.did_ftplugin = 1

-- Save and reset 'cpoptions'
local cpo_save = vim.o.cpoptions
vim.cmd('set cpo&vim')

-- Conditional folding
if vim.g.plsql_fold == 1 then
  vim.opt_local.foldmethod = 'syntax'
  vim.b.undo_ftplugin = 'setlocal foldmethod<'
end

-- Restore 'cpoptions'
vim.o.cpoptions = cpo_save

