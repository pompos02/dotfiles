return {
    "tzachar/local-highlight.nvim",
    opts = {
        hlgroup = "LocalHighlight",
        cw_hlgroup = "LocalCursorHighlight",
        animate = false,
    },
    config = function(_, opts)
        -- underline for all matches
        vim.api.nvim_set_hl(0, "LocalHighlight", {
            underline = true,
            default = true,
        })

        -- stronger underline for word under cursor
        vim.api.nvim_set_hl(0, "LocalCursorHighlight", {
            underline = true,
            bold = true,
            default = true,
        })

        -- reapply after colorscheme changes
        vim.api.nvim_create_autocmd("ColorScheme", {
            callback = function()
                vim.api.nvim_set_hl(0, "LocalHighlight", {
                    underline = true,
                    default = true,
                })
                vim.api.nvim_set_hl(0, "LocalCursorHighlight", {
                    underline = true,
                    bold = true,
                    default = true,
                })
            end,
        })

        require("local-highlight").setup(opts)
    end,
}

