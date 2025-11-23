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

  vim.map("i", "<C-e>", function()
    if vim.fn.pumvisible() == 1 then
      return "<C-e>"
    else
      return "<C-e>"
    end
  end, { expr = true, silent = true, desc = "Close completion" })
end

return M
