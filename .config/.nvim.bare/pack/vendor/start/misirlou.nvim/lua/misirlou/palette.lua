-- tes
local options = require("misirlou.config").options

local palettes = {
    resu = {
        bg = "#000000",
        nc = "#000000",
        base = "#121212",
        surface = "#1e1e1e",
        overlay = "#2a2a2a",
        muted = "#404040",
        subtle = "#4a4a4a",
        text = "#dbdbdb",
        red = "#d38a95",
        gold = "#d3a677",
        rose = "#d69797",
        blue = "#8c9ab0",
        lavender = "#a2a2c7",
        purple = "#b28fb2",
        green = "#8fad9e",

        highlight_low = "#1e1e1e",
        highlight_med = "#282828",
        highlight_high = "#707070",
    },
    cool = {
        bg = "#000000",
        nc = "#000000",
        base = "#121212",
        surface = "#1e1e1e",
        overlay = "#2a2a2a",
        muted = "#404040",
        subtle = "#4a4a4a",
        text = "#dbdbdb",
        red = "#d46a6a",
        gold = "#c9976c",
        rose = "#c37373",
        blue = "#6a7e9b",
        lavender = "#7979a7",
        purple = "#9b6f9b",
        green = "#75a195",

        highlight_low = "#1e1e1e",
        highlight_med = "#282828",
        highlight_high = "#707070",
    },

    dragon = {
        bg = "#000000",
        nc = "#000000",
        base = "#12120f",
        surface = "#1D1C19",
        overlay = "#181616",
        muted = "#282727",
        subtle = "#393836",
        text = "#c5c9c5",
        red = "#c4746e",
        gold = "#b6927b",
        rose = "#a292a3",
        blue = "#8ba4b0",
        lavender = "#8992a7",
        purple = "#c4b28a",
        green = "#87a987",
        highlight_low = "#1D1C19",
        highlight_med = "#181616",
        highlight_high = "#625e5a",
    },
    lightstrong = {
        bg = "#ffffff",
        nc = "#ffffff",
        base = "#ffffff",
        surface = "#f5f5f5",
        overlay = "#eeeeee",
        muted = "#999999",
        subtle = "#666666",
        text = "#1a1a1a",
        red = "#ce192b",
        gold = "#42aa1d",
        rose = "#14a8bb",
        blue = "#1b79c5",
        lavender = "#a022c5",
        purple = "#de7a35",
        green = "#e2b051",
        highlight_low = "#f0f0f0",
        highlight_med = "#e0e0e0",
        highlight_high = "#d0d0d0",
    },
    lb = {
        bg = "#000000",
        nc = "#000000",
        base = "#000000",
        surface = "#1a1a1a",
        overlay = "#2a2a2a",
        muted = "#666666",
        subtle = "#999999",
        text = "#ffffff",
        red = "#d94c5a",
        gold = "#8ec07c",
        rose = "#56b6c2",
        blue = "#61afef",
        lavender = "#c678dd",
        purple = "#de935f",
        green = "#e5c07b",
        highlight_low = "#1a1a1a",
        highlight_med = "#2a2a2a",
        highlight_high = "#3a3a3a",
    },
    des = {
        bg = "#000000",
        nc = "#000000",
        base = "#222222",
        surface = "#262626",
        overlay = "#2c2c2c",
        muted = "#4b4b4b",
        subtle = "#6a6a6a",
        text = "#e0e0e0",
        red = "#e56c6c",
        gold = "#8ec07c",
        rose = "#de935f",
        blue = "#e56c6c",
        lavender = "#9db2f0",
        purple = "#b07de5",
        green = "#6c92e5",
        highlight_low = "#232323",
        highlight_med = "#2a2a2a",
        highlight_high = "#3a3a3a",
    },
    git = {
        bg = "#000000",
        nc = "#000000",
        base = "#222222",
        surface = "#262626",
        overlay = "#2c2c2c",
        muted = "#4b4b4b",
        subtle = "#6a6a6a",
        text = "#e0e0e0",
        red = "#e56c6c", --red 
        gold = "#8ec07c", --green
        rose = "#FFA657", --orage
        blue = "#FF7B72", --red

        lavender = "#A5D6FF", --blue
        green = "#79C0FF",  --darkerblue

        purple = "#D2A8FF", --purple
        highlight_low = "#232323",
        highlight_med = "#2a2a2a",
        highlight_high = "#3a3a3a",
    },
    gitg = {
        bg = "#0D1117",
        nc = "#0D1117",
        base = "#222222",
        surface = "#262626",
        overlay = "#2c2c2c",
        muted = "#4b4b4b",
        subtle = "#9198A1",
        text = "#e0e0e0",
        red = "#e56c6c", --red 
        gold = "#8ec07c", --green
        rose = "#FFA657", --orage
        blue = "#FF7B72", --red

        lavender = "#A5D6FF", --blue
        green = "#79C0FF",  --darkerblue

        purple = "#D2A8FF", --purple
        highlight_low = "#232323",
        highlight_med = "#2a2a2a",
        highlight_high = "#3a3a3a",
    }

}

local function get_variant()
    if vim.g.colors_name == "misirlou-cool" then
        return "cool"
    elseif vim.g.colors_name == "misirlou-dragon" then
        return "dragon"
    elseif vim.g.colors_name == "misirlou-des" then
        return "des"
    elseif vim.g.colors_name == "misirlou-git" then
        return "git"
    elseif vim.g.colors_name == "misirlou-gitg" then
        return "gitg"
    elseif vim.g.colors_name == "misirlou-lightstrong" then
        return "lightstrong"
    elseif vim.g.colors_name == "misirlou-lb" then
        return "lb"
    elseif vim.g.colors_name == "misirlou-resu" then
        return "resu"
    end

    return options.variant or "cool"
end

local variant = get_variant()
local palette = palettes[variant] or palettes.cool

if options.palette ~= nil and next(options.palette) then
    palette = vim.tbl_extend("force", palette, options.palette or {})
end

return palette
