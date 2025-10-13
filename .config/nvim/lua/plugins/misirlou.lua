return {
    "pompos02/misirlou.nvim",
    name = "misirlou.nvim",
    config = function()
        require("misirlou").setup({

            palette = {
                bg = "#000000",
                nc = "#000000",
                base = "#1b1b1b",
                surface = "#1c1c24",
                overlay = "#313131",
                muted = "#898989",
                subtle = "#b2b2b2",
                text = "#fbfbfb",
                red = "#c77889",
                gold = "#dfb591",
                rose = "#ba8d8d",
                blue = "#7c98b9",
                lavender = "#9f9fcf",
                purple = "#bb9dbd",
                green = "#a7c1bd",
                highlight_low = "#262626",
                highlight_med = "#4f4f4f",
                highlight_high = "#797979",
            },
        })
    end,
}
