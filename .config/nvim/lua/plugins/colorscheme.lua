return {
    -- The rose-pine colorscheme plugin
    {
        "rose-pine/neovim",
        name = "rose-pine",
        config = function()
            require("rose-pine").setup({
                variant = "auto",
                dark_variant = "moon",
                dim_inactive_windows = true,
                disable_float_background = true,
                styles = {
                    transparency = false,
                },
                palette = {
                    moon = {
                        bg = "#0f0e1a",
                        _nc = "#1f1d30",
                        base = "#232136",
                        surface = "#2a273f",
                        overlay = "#393552",
                        muted = "#6e6a86",
                        subtle = "#908caa",
                        text = "#e0def4",
                        love = "#eb6f92",
                        gold = "#f6c177",
                        rose = "#ea9a97",
                        pine = "#3e8fb0",
                        foam = "#9ccfd8",
                        iris = "#c4a7e7",
                        leaf = "#95b1ac",
                        highlight_low = "#2a283e",
                        highlight_med = "#44415a",
                        highlight_high = "#56526e",
                        none = "NONE",
                    },
                },
                highlight_groups = {
                    Normal = { fg = "text", bg = "bg" },
                    IncSearch = { fg = "base", bg = "love" },
                    -- Set floating windows to use terminal background
                    NormalFloat = { fg = "text", bg = "bg" },
                    FloatBorder = { fg = "muted", bg = "bg" },
                    -- Snacks picker specific
                    SnacksPicker = { fg = "text", bg = "bg" },
                    SnacksPickerBorder = { fg = "muted", bg = "bg" },
                    SnacksPickerList = { fg = "text", bg = "bg" },
                    SnacksPickerPreview = { fg = "text", bg = "bg" },
                    SnacksPickerInput = { fg = "text", bg = "bg" },
                    -- Active line highlighting
                    CursorLine = { bg = "highlight_low" },
                    -- Visual selection highlighting
                    Visual = { bg = "iris" },
                    -- Keywords (package, import, type, func, etc.)
                },
            })
        end,
    },
}
