local M = {}
local config = require("misirlou.config")

local colorschemes = {
    cool = "misirlou-cool",
    des = "misirlou-des",
    git = "misirlou-git",
    gitg = "misirlou-gitg",
    resu = "misirlou-resu",
    dragon = "misirlou-dragon",
    lightstrong = "misirlou-lightstrong",
    lb = "misirlou-lb",
}

function M.setup(options)
    config.extend_options(options or {})
end

function M.colorscheme()
    local variant = config.options.variant or "cool"
    vim.cmd("colorscheme " .. (colorschemes[variant] or colorschemes.cool))
end

return M
