return {
    {
        name = "mini-surround-basic",
        dir = vim.fn.stdpath("config"),
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("mini_surround_basic").setup({
                custom_surroundings = nil,
                mappings = {
                    add = "sa",
                    delete = "sd",
                    replace = "sr",
                },
                n_lines = 20,
                respect_selection_type = false,
                search_method = "cover",
                silent = false,
            })
        end,
    },
}
