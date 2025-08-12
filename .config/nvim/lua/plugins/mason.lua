return {
    {
        "mason-org/mason.nvim",
        cmd = "Mason",
        keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
        build = ":MasonUpdate",
        opts = {
            install_root_dir = vim.fn.stdpath("data") .. "/mason",
            PATH = "prepend",
            max_concurrent_installers = 4,
        },
    },
}
