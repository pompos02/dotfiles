local p = require("misirlou.palette")
local config = require("misirlou.config")

local bg_base = p.surface
if config.options.styles.transparency then
    bg_base = "NONE"
end

return {
    normal = {
        a = { bg = p.rose, fg = p.base, gui = "bold" },
        b = { bg = p.overlay, fg = p.rose },
        c = { bg = bg_base, fg = p.text },
    },
    insert = {
        a = { bg = p.lavender, fg = p.base, gui = "bold" },
        b = { bg = p.overlay, fg = p.lavender },
        c = { bg = bg_base, fg = p.text },
    },
    visual = {
        a = { bg = p.purple, fg = p.base, gui = "bold" },
        b = { bg = p.overlay, fg = p.purple },
        c = { bg = bg_base, fg = p.text },
    },
    replace = {
        a = { bg = p.blue, fg = p.base, gui = "bold" },
        b = { bg = p.overlay, fg = p.blue },
        c = { bg = bg_base, fg = p.text },
    },
    command = {
        a = { bg = p.red, fg = p.base, gui = "bold" },
        b = { bg = p.overlay, fg = p.red },
        c = { bg = bg_base, fg = p.text },
    },
    inactive = {
        a = { bg = bg_base, fg = p.muted, gui = "bold" },
        b = { bg = bg_base, fg = p.muted },
        c = { bg = bg_base, fg = p.muted },
    },
}
