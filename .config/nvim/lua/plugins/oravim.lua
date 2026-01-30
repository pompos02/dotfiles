return {
    dir = "/home/karavellas/projects/opensource/oravim.nvim",
    -- "pompos02/oravim.nvim",
    config = function()
        require("oravim").setup({
            cli = "sqlplus",
            drawer = {
                width = 40,
                position = "left", -- "left" or "right"
            },
            use_nerd_fonts = true,
            max_completion_items = 5000,
            query = {
                filetype = "plsql",
                default = "SELECT * FROM {optional_schema}{table};",
                new_query = "",
                execute_on_save = false,
                tmp_dir = "/tmp/oravim",
                saved_dir = vim.fn.stdpath("data") .. "/oravim/saved_queries",
            },
        })
    end,

}
