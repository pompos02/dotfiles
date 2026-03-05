-- vim.b.completion = false
vim.opt.wrap = true
vim.cmd("set keywordprg=dict")
--
-- Look up the word under the cursor and display it in a new buffer
vim.keymap.set('n', 'K', function()
  local word = vim.fn.expand("<cword>")
  vim.cmd('new')
  vim.cmd('read !dict ' .. word)
  vim.bo.buftype = 'nofile'
  vim.bo.bufhidden = 'hide'
  vim.bo.swapfile = false
end, { desc = 'Dictionary lookup word' })
