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
        config = function(_, opts)
            require("mason").setup(opts)
            local mr = require("mason-registry")
            -- Ensure installed packages
            local packages = {
                "lua-language-server",
                "prettier",
                "stylua",
                "shfmt",
                "goimports",
                "gofumpt",
                "gopls",
                "ruff",
                "eslint_d",
                "elixir-ls",
                "golangci-lint",
            }
            for _, package in ipairs(packages) do
                local p = mr.get_package(package)
                if not p:is_installed() then
                    p:install()
                end
            end
        end,
    },
    {
        "mason-org/mason-lspconfig.nvim",
        dependencies = { "mason.nvim" },
        opts = {
            ensure_installed = {
                "lua_ls", -- Only LSP server names here
                "basedpyright",
                "ts_ls",
            },
            automatic_installation = true,
        },
    },
}
