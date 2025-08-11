return {
  "neovim/nvim-lspconfig",
  config = function()
    local lspconfig = require("lspconfig")
    
    lspconfig.elixirls.setup({})
    
    vim.keymap.set("n", "<leader>cp", function()
      local params = vim.lsp.util.make_position_params()
      vim.lsp.buf.execute_command({
        command = "manipulatePipes:serverid",
        arguments = {
          "toPipe",
          params.textDocument.uri,
          params.position.line,
          params.position.character,
        },
      })
    end, { desc = "To Pipe" })
    
    vim.keymap.set("n", "<leader>cP", function()
      local params = vim.lsp.util.make_position_params()
      vim.lsp.buf.execute_command({
        command = "manipulatePipes:serverid",
        arguments = {
          "fromPipe",
          params.textDocument.uri,
          params.position.line,
          params.position.character,
        },
      })
    end, { desc = "From Pipe" })
  end,
}
