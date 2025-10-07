return {
    "pompos02/misirlou.nvim",
    name = "misirlou.nvim",
    config = function()
        require("misirlou").setup({

            palette = {
                bg = "#000000",
                nc = "#000000",
                base = "#16151a",
                surface = "#1c1c24",
                overlay = "#252530",
                muted = "#56526e",
                subtle = "#6e6a86",
                text = "#dbdbdb",
                red = "#c77889",
                gold = "#dfb591",
                rose = "#ba8d8d",
                blue = "#7c98b9",
                lavender = "#9f9fcf",
                purple = "#bb9dbd",
                green = "#a7c1bd",
                highlight_low = "#1a1826",
                highlight_med = "#2a283e",
                highlight_high = "#44415a",
            },
        })
    end,
}
