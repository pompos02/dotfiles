require("snacks").indent.enable()

-- Run Python file in new window below with <leader>rr
vim.keymap.set('n', '<leader>rr', function()
  vim.cmd('15split')  -- Creates a 15-line high split
  vim.cmd('terminal python ' .. vim.fn.expand('%'))
end, { buffer = true, desc = 'Run Python file in new window below' })