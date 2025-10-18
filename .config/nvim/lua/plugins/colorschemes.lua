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
            require("misirlou").setup({
                palette = {
                    bg = "#000000",
                    nc = "#000000",
                    base = "#121212",
                    surface = "#1e1e1e",
                    overlay = "#2a2a2a",
                    muted = "#404040",
                    subtle = "#4a4a4a",
                    text = "#c0c0c0",
                    red = "#9a5f68",
                    gold = "#a27d63",
                    rose = "#9f6f6f",
                    blue = "#5a6472",
                    lavender = "#72728b",
                    purple = "#7f6a7f",
                    green = "#6b7d78",

                    highlight_low = "#1e1e1e",
                    highlight_med = "#282828",
                    highlight_high = "#707070",
                },
            })
        end,
    },
    {
        "pompos02/misirloun.nvim",
        name = "misirloun",
        config = function()
            require("misirloun").setup({
                palette = {
                    c1 = "#000000",
                    c2 = "#080808",
                    c3 = "#191919",
                    c4 = "#2a2a2a",
                    c5 = "#444444",
                    c6 = "#666666",
                    c7 = "#DDDDDD",
                    c70 = "#b4b4b4",
                    red = "#ce8787",
                    gold = "#d4ab5f",
                    green = "#789978",
                    string = "#7788AA",
                    white = "#ffffff",
                },
            })
        end,
    },
}
