return {
    "nvim-treesitter/nvim-treesitter-context",
    event = "LazyFile",
    opts = function()
        local tsc = require("treesitter-context")
        Snacks.toggle({
            name = "Treesitter Context",
            get = tsc.enabled,
            set = function(state)
                if state then
                    tsc.enable()
                else
                    tsc.disable()
                end
            end,
        }):map("<leader>ut")
        return { mode = "cursor", max_lines = 3 }
    end,
    config = function(_, opts)
        require("treesitter-context").setup(opts)
        vim.cmd([[highlight TreesitterContext guibg=NONE]])
        vim.cmd([[highlight TreesitterContextBottom gui=underline guisp=overlay]])
        
        -- Set background to overlay color after colorscheme loads
        vim.api.nvim_create_autocmd("ColorScheme", {
            callback = function()
                local colors = require("rose-pine.palette")
                vim.api.nvim_set_hl(0, "TreesitterContext", { bg = colors.overlay })
                vim.api.nvim_set_hl(0, "TreesitterContextBottom", { underline = true, sp = colors.overlay })
            end,
        })
    end,
}
