return {
  "stevearc/oil.nvim",
  keys = {
    { "<leader>e", "<cmd>Oil --float<CR>", desc = "Explorer" },
    {
      "<leader>E",
      function()
        require("oil").open_float(vim.fn.getcwd())
      end,
      desc = "Explorer (Oil) - Project Root",
    },
  },
  opts = {
    view_options = {
      show_hidden = true,
    },
    float = {
      padding = 5,
    },
    default_file_explorer = true,
  },
  -- Optional dependencies
  dependencies = { "nvim-tree/nvim-web-devicons" },
}

