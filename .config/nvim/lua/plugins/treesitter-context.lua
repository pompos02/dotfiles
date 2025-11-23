return {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    keys = {
        {
            "<leader>ut",
            function()
                local tsc = require("treesitter-context")
                if tsc.enabled() then
                    tsc.disable()
                    vim.notify("Treesitter Context disabled", vim.log.levels.INFO)
                else
                    tsc.enable()
                    vim.notify("Treesitter Context enabled", vim.log.levels.INFO)
                end
            end,
            desc = "Toggle Treesitter Context",
        },
    },
    opts = {
        mode = "cursor",
        max_lines = 3,
    },
    config = function(_, opts)
        require("treesitter-context").setup(opts)
        vim.cmd([[highlight TreesitterContext guibg=NONE]])
        vim.cmd([[highlight TreesitterContextBottom gui=underline guisp=overlay]])
    end,
}
