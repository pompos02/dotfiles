return {
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
}
