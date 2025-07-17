return {
    "stevearc/oil.nvim",
    -- keys = {
    --     { "<leader>e", "<cmd>Oil<CR>", desc = "Explorer" },
    -- },
    opts = {
        view_options = {
            show_hidden = true,
        },
        float = {
            padding = 5,
        },
    },
    -- Optional dependencies
    dependencies = { "nvim-tree/nvim-web-devicons" },
}
