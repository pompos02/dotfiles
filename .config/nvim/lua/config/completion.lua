-- Native omnifunc completion setup
-- Replaces blink.cmp with built-in Neovim completion
local M = {}

M.setup = function()
  -- Use LSP omnifunc when LSP attaches
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("lsp_completion", { clear = true }),
    callback = function(args)
      vim.bo[args.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
    end,
  })

  -- Completion mappings
  local map = vim.keymap.set
  
  
  -- Tab/S-Tab for navigation in completion menu
  map("i", "<Tab>", function()
    if vim.fn.pumvisible() == 1 then
      return "<C-n>"
    else
      return "<Tab>"
    end
  end, { expr = true, silent = true, desc = "Next completion" })
  
  map("i", "<S-Tab>", function()
    if vim.fn.pumvisible() == 1 then
      return "<C-p>"
    else
      return "<S-Tab>"
    end
  end, { expr = true, silent = true, desc = "Previous completion" })
  
  -- Enter to select completion
  map("i", "<CR>", function()
    if vim.fn.pumvisible() == 1 then
      return "<C-y>"
    else
      return "<CR>"
    end
  end, { expr = true, silent = true, desc = "Accept completion" })
  
  -- Ctrl+e to close completion menu
  map("i", "<C-e>", function()
    if vim.fn.pumvisible() == 1 then
      return "<C-e>"
    else
      return "<C-e>"
    end
  end, { expr = true, silent = true, desc = "Close completion" })
end

return M
