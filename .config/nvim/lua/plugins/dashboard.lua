return {
    {
        "snacks.nvim",
        opts = {
            dashboard = {
                enabled = true,
                sections = {
                    {
                        text = {
                            "NVIM v" .. vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch,
                        },
                        align = "center",
                    },
                },
            },
        },
    },
}
