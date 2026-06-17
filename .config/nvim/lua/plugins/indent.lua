return {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
        indent = {
            char = "┊",
        },
        scope = {
            enabled = true,
            show_start = false,
            show_end = false,
            char = "│",
            include = {
                node_type = {
                    ["*"] = {
                        "return_statement",
                        "function_call",
                    },
                    lua = {
                        "field",
                    },
                    rust = {
                        "let_declaration",
                        "call_expression",
                        "arguments",
                        -- "field_expression",
                        "closure_expression",
                    },
                },
            },
        },
    },
}
