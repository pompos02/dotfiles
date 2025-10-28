-- Colorschemes
return {
    {
        "slugbyte/lackluster.nvim",
        lazy = false,
        priority = 1000,
        init = function() end,
    },
    {
        "pompos02/misirlou.nvim",
        name = "misirlou.nvim",
        config = function()
            require("misirlou").setup({})
        end,
    },
    {
        "pompos02/misirloun.nvim",
        name = "misirloun",
        config = function()
            require("misirloun").setup({
                palette = {
                    -- c1 = "#000000",
                    -- c2 = "#080808",
                    -- c3 = "#191919",
                    -- c4 = "#2a2a2a",
                    -- c5 = "#444444",
                    -- c6 = "#666666",
                    -- c7 = "#DDDDDD",
                    -- c70 = "#b4b4b4",
                    -- red = "#ce8787",
                    -- gold = "#d4ab5f",
                    -- green = "#789978",
                    -- string = "#7788AA",
                    -- white = "#ffffff",
                },
            })
        end,
    },
    { "shaunsingh/nord.nvim", name = "nord" },
    {
        -- dir = "~/plugins/colorbuddy.nvim",
        "tjdevries/colorbuddy.nvim",
        -- config = function()
        --     vim.cmd.colorscheme("gruvbuddy")
        -- end,
    },
    { "rose-pine/neovim",     name = "rose-pine" },
    "miikanissi/modus-themes.nvim",
    "rebelot/kanagawa.nvim",
    "folke/tokyonight.nvim",
    "ntk148v/komau.vim",
    { "catppuccin/nvim",       name = "catppuccin" },
    { "EdenEast/nightfox.nvim" },
    "sainnhe/gruvbox-material",
    "neanias/everforest-nvim",
    "datsfilipe/vesper.nvim",
    "vague2k/vague.nvim",
    "ellisonleao/gruvbox.nvim",
}
