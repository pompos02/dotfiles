return {
    -- dir = "/home/karavellas/repos/fff",
    "dmtrKovalenko/fff.nvim",
    -- "pompos02/fff",
    -- branch = "feat/query-match-highlights",
    -- dir = "/home/karavellas/projects/opensource/fff-fork",
    branch = "main",
    name = "fff.nvim",
    build = "cargo +stable build --release",
    opts = {

        prompt = vim.fn.fnamemodify(vim.fn.getcwd(), ':~') .. '/',
        enable_content_indexing = false,
        watch = false,
        file_picker = {
            fuzzy_query_highlighting = true, -- true to highlight fuzzy query matches in file picker results
        },
        hl = {
            directory_path = 'Text',
            winhl = {
                prompt = 'Special:MyFFFPrompt',
            },
        },
        layout = {
            height = 1,
            width = 1,
            prompt_position = "top", -- or 'top'
            show_path_first = true, -- true renders results as `path/to/file` instead of `file path/to`
            -- preview_position = "right", -- keep results on the left, preview on the right
            preview_size = 0.4,
            flex = false,
            show_scrollbar = true, -- Show scrollbar for pagination
            -- How to shorten long directory paths in the file list:
            -- 'middle_number' (default): uses dots for 1-3 hidden (a/./b, a/../b, a/.../b)
            --                            and numbers for 4+ (a/.4./b, a/.5./b)
            -- 'middle': always uses dots (a/./b, a/../b, a/.../b)
            -- 'end': truncates from the end (home/user/projects)
            -- path_shorten_strategy = "middle_number",
        },

        debug = {
            enabled = true,
            show_scores = true,
        },

        keymaps = {
            cycle_previous_query = '<C-p>',
            cycle_forward_query = '<C-n>',
            move_up = '<Up>',
            move_down = '<Down>',
            clear_query = '<C-u>',
        },
    },
    lazy = false, -- the plugin lazy-initialises itself
    keys = {
        { "<leader><leader>", function() require('fff').find_files() end, desc = 'FFFind files' },
        { "<leader>pg",       function() require('fff').live_grep() end,  desc = 'LiFFFe grep' },
        {
            "fz",
            function() require('fff').live_grep({ grep = { modes = { 'fuzzy', 'plain' } } }) end,
            desc = 'Live fffuzy grep',
        },
        {
            "fc",
            function() require('fff').live_grep({ query = vim.fn.expand("<cword>") }) end,
            desc = 'Search current word',
        },
    },
}
