return {
    "rebelot/kanagawa.nvim",
    config = function()
        require("kanagawa").setup({
            overrides = function()
                return {
                    Identifier = { link = "Variable" },
                    ["@variable"] = { link = "Variable" },
                }
            end,
        })
    end,
}
