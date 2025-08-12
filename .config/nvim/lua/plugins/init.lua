return {
    -- The rose-pine colorscheme plugin
    {
        "rose-pine/neovim",
        name = "rose-pine",
        -- It is highly recommended to use the "config" key
        -- to set up the colorscheme. This ensures it's loaded
        -- *before* we try to use it with `vim.cmd`.
        config = function()
            require("rose-pine").setup({
                variant = "auto",
                dark_variant = "moon",
                dim_inactive_windows = true,
                extend_background_behind_borders = true,
                enable = {
                    terminal = true,
                    legacy_highlights = true,
                    migrations = true,
                },
                styles = {
                    bold = true,
                    italic = true,
                    transparency = true,
                },
                groups = {
                    border = "highlight_high",
                    link = "iris",
                    panel = "base",
                    error = "love",
                    hint = "iris",
                    info = "foam",
                    note = "pine",
                    todo = "rose",
                    warn = "gold",
                    git_add = "foam",
                    git_change = "rose",
                    git_delete = "love",
                    git_dirty = "rose",
                    git_ignore = "muted",
                    git_merge = "iris",
                    git_rename = "pine",
                    git_stage = "iris",
                    git_text = "rose",
                    git_untracked = "subtle",
                    headings = {
                        h1 = "love",
                        h2 = "rose",
                        h3 = "iris",
                        h4 = "gold",
                        h5 = "foam",
                        h6 = "pine",
                    },
                },
                palette = {
                    main = {
                        base = "#191724",
                        surface = "#1f1d2e",
                        overlay = "#26233a",
                        muted = "#6e6a86",
                        subtle = "#908caa",
                        text = "#e0def4",
                        love = "#eb6f92",
                        gold = "#fac75a",
                        rose = "#ebbcba",
                        pine = "#31748f",
                        foam = "#9ccfd8",
                        iris = "#c4a7e7",
                        highlight_low = "#21202e",
                        highlight_med = "#403d52",
                        highlight_high = "#524f67",
                    },
                    moon = {
                        base = "#0f0e1a",
                        surface = "#16141f",
                        overlay = "#1e1c2a",
                        muted = "#6e6a86",
                        subtle = "#a8a5c0",
                        text = "#e0def4",
                        love = "#ff5d7a",
                        gold = "#ffb347",
                        rose = "#f5a6b6",
                        pine = "#40a4c4",
                        foam = "#66deb2",
                        iris = "#d4a7ff",
                        highlight_low = "#1a1825",
                        highlight_med = "#2a2837",
                        highlight_high = "#3a3649",
                    },
                },
                highlight_groups = {
                    Comment = { fg = "muted", italic = true },
                    Keyword = { fg = "pine", bold = true },
                    Function = { fg = "rose", bold = true },
                    String = { fg = "gold" },
                    Number = { fg = "iris" },
                    Boolean = { fg = "love", bold = true },
                    Operator = { fg = "subtle", bold = true },
                    Type = { fg = "foam", bold = true },
                    Variable = { fg = "text" },
                    Constant = { fg = "love", bold = true },
                    Normal = { fg = "text" },
                    NormalFloat = { fg = "text" },
                    FloatBorder = { fg = "highlight_high" },
                    CursorLine = { bg = "highlight_med" },
                    Visual = { bg = "rose" },
                    VisualNOS = { bg = "iris" },
                    Search = { fg = "base", bg = "gold" },
                    IncSearch = { fg = "base", bg = "love" },
                    SignColumn = { fg = "text" },
                    EndOfBuffer = { fg = "muted" },
                    VertSplit = { fg = "highlight_high" },
                    WinSeparator = { fg = "highlight_high" },
                    NormalNC = { fg = "muted" },
                    CursorLineNr = { fg = "rose", bold = true },
                    LineNr = { fg = "subtle" },
                    LineNrAbove = { fg = "muted" },
                    LineNrBelow = { fg = "muted" },
                    DiagnosticError = { fg = "love", bold = true },
                    DiagnosticWarn = { fg = "gold", bold = true },
                    DiagnosticInfo = { fg = "foam", bold = true },
                    DiagnosticHint = { fg = "iris", bold = true },
                    DiagnosticUnderlineError = { undercurl = true, sp = "love" },
                    DiagnosticUnderlineWarn = { undercurl = true, sp = "gold" },
                    DiagnosticUnderlineInfo = { undercurl = true, sp = "foam" },
                    DiagnosticUnderlineHint = { undercurl = true, sp = "iris" },
                    BlinkCmpMenu = { fg = "text", bg = "surface" },
                    BlinkCmpMenuBorder = { fg = "highlight_high", bg = "surface" },
                    BlinkCmpMenuSelection = { fg = "base", bg = "rose", bold = true },
                    BlinkCmpLabel = { fg = "text" },
                    BlinkCmpLabelDeprecated = { fg = "muted", strikethrough = true },
                    BlinkCmpLabelMatch = { fg = "love", bold = true },
                    BlinkCmpKind = { fg = "iris", bold = true },
                    BlinkCmpKindText = { fg = "foam", bold = true },
                    BlinkCmpKindMethod = { fg = "love", bold = true },
                    BlinkCmpKindFunction = { fg = "rose", bold = true },
                    BlinkCmpKindConstructor = { fg = "gold", bold = true },
                    BlinkCmpKindField = { fg = "foam" },
                    BlinkCmpKindVariable = { fg = "iris" },
                    BlinkCmpKindClass = { fg = "gold", bold = true },
                    BlinkCmpKindInterface = { fg = "gold", bold = true },
                    BlinkCmpKindModule = { fg = "pine", bold = true },
                    BlinkCmpKindProperty = { fg = "foam" },
                    BlinkCmpKindUnit = { fg = "gold" },
                    BlinkCmpKindValue = { fg = "rose" },
                    BlinkCmpKindEnum = { fg = "gold", bold = true },
                    BlinkCmpKindKeyword = { fg = "pine", bold = true },
                    BlinkCmpKindSnippet = { fg = "rose", bold = true },
                    BlinkCmpKindColor = { fg = "love" },
                    BlinkCmpKindFile = { fg = "foam" },
                    BlinkCmpKindReference = { fg = "foam" },
                    BlinkCmpKindFolder = { fg = "foam", bold = true },
                    BlinkCmpKindEnumMember = { fg = "gold" },
                    BlinkCmpKindConstant = { fg = "love", bold = true },
                    BlinkCmpKindStruct = { fg = "gold", bold = true },
                    BlinkCmpKindEvent = { fg = "gold" },
                    BlinkCmpKindOperator = { fg = "subtle", bold = true },
                    BlinkCmpKindTypeParameter = { fg = "gold" },
                    BlinkCmpDoc = { fg = "text", bg = "overlay" },
                    BlinkCmpDocBorder = { fg = "highlight_high", bg = "overlay" },
                    BlinkCmpDocCursorLine = { bg = "highlight_med" },
                    BlinkCmpGhostText = { fg = "subtle" },
                    BlinkCmpSignatureHelp = { fg = "text", bg = "overlay" },
                    BlinkCmpSignatureHelpBorder = { fg = "highlight_high", bg = "overlay" },
                    BlinkCmpSignatureHelpActiveParameter = { fg = "love", bold = true, bg = "highlight_low" },
                    -- ["@keyword"] = { fg = "pine", bold = true },
                    -- ["@keyword.function"] = { fg = "pine", bold = true },
                    -- ["@keyword.return"] = { fg = "pine", bold = true },
                    -- ["@function"] = { fg = "rose", bold = true },
                    -- ["@function.builtin"] = { fg = "love", bold = true },
                    -- ["@method"] = { fg = "rose", bold = true },
                    -- ["@variable"] = { fg = "text" },
                    -- ["@variable.builtin"] = { fg = "love", italic = true },
                    -- ["@string"] = { fg = "gold" },
                    -- ["@number"] = { fg = "iris", bold = true },
                    -- ["@boolean"] = { fg = "love", bold = true },
                    -- ["@type"] = { fg = "foam", bold = true },
                    -- ["@type.builtin"] = { fg = "love", bold = true },
                    -- ["@constructor"] = { fg = "gold", bold = true },
                    -- ["@tag"] = { fg = "foam", bold = true },
                    -- ["@tag.attribute"] = { fg = "iris" },
                    -- ["@tag.delimiter"] = { fg = "subtle" },
                    -- ["@symbol"] = { fg = "iris", italic = true },
                    -- ["@string.special.symbol"] = { fg = "iris", italic = true },
                    -- ["@parameter"] = { fg = "foam", italic = true },
                    -- ["@variable.parameter"] = { fg = "foam", italic = true },
                    -- ["@field"] = { fg = "foam" },
                    -- ["@property"] = { fg = "foam" },
                    -- ["@attribute"] = { fg = "rose" },
                    -- ["@constant"] = { fg = "love", bold = true },
                    -- ["@constant.builtin"] = { fg = "love", bold = true },
                    -- ["@namespace"] = { fg = "pine", bold = true },
                    ["@keyword.elixir"] = { fg = "pine", bold = true },
                    ["@atom.elixir"] = { fg = "iris", italic = true },
                    ["@variable.elixir"] = { fg = "text" },
                    ["@function.call.elixir"] = { fg = "rose", bold = true },
                    ["@punctuation.bracket"] = { fg = "subtle" },
                    ["@punctuation.delimiter"] = { fg = "subtle" },
                    ["@operator"] = { fg = "text", bold = true },
                    ["@keyword.operator"] = { fg = "rose", bold = true },
                    ["@type.qualifier"] = { fg = "pine", italic = true },
                    ["@storageclass"] = { fg = "pine", bold = true },
                },
                before_highlight = function(group, highlight, palette)
                    if group == "Normal" then
                        highlight.bg = "NONE"
                    end
                    if group == "NormalNC" then
                        highlight.bg = "NONE"
                        highlight.fg = palette.muted
                    end
                    if group == "SignColumn" then
                        highlight.bg = "NONE"
                    end
                    if group == "EndOfBuffer" then
                        highlight.bg = "NONE"
                    end
                    if group == "StatusLine" then
                        highlight.bg = palette.overlay
                        highlight.fg = palette.text
                    end
                    if group == "StatusLineNC" then
                        highlight.bg = palette.base
                        highlight.fg = palette.muted
                    end
                    if group == "TabLine" then
                        highlight.bg = palette.base
                        highlight.fg = palette.subtle
                    end
                    if group == "TabLineSel" then
                        highlight.bg = palette.foam
                        highlight.fg = palette.base
                        highlight.bold = true
                    end
                end,
            })
        end,
    },

    -- The lualine plugin
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "rose-pine/neovim" }, -- Add this to ensure rose-pine loads first
        config = function()
            local rose_pine = require("rose-pine.palette")

            -- Create the vibrant lualine theme based on your rose-pine palette
            local vibrant_rose_pine = {
                normal = {
                    a = { fg = rose_pine.base, bg = rose_pine.rose, gui = "bold" },
                    b = { fg = rose_pine.rose, bg = rose_pine.base },
                    c = { fg = rose_pine.text, bg = rose_pine.base },
                },
                insert = {
                    a = { fg = rose_pine.base, bg = rose_pine.foam, gui = "bold" },
                    b = { fg = rose_pine.foam, bg = rose_pine.base },
                    c = { fg = rose_pine.text, bg = rose_pine.base },
                },
                visual = {
                    a = { fg = rose_pine.base, bg = rose_pine.iris, gui = "bold" },
                    b = { fg = rose_pine.iris, bg = rose_pine.base },
                    c = { fg = rose_pine.text, bg = rose_pine.base },
                },
                replace = {
                    a = { fg = rose_pine.base, bg = rose_pine.love, gui = "bold" },
                    b = { fg = rose_pine.love, bg = rose_pine.base },
                    c = { fg = rose_pine.text, bg = rose_pine.base },
                },
                command = {
                    a = { fg = rose_pine.base, bg = rose_pine.pine, gui = "bold" },
                    b = { fg = rose_pine.pine, bg = rose_pine.base },
                    c = { fg = rose_pine.text, bg = rose_pine.base },
                },
                inactive = {
                    a = { fg = rose_pine.muted, bg = rose_pine.base },
                    b = { fg = rose_pine.muted, bg = rose_pine.base },
                    c = { fg = rose_pine.muted, bg = rose_pine.base },
                },
            }

            -- Set up lualine
            require("lualine").setup({
                options = {
                    theme = vibrant_rose_pine,
                    component_separators = { left = "", right = "" },
                    section_separators = { left = "", right = "" },
                    globalstatus = true,
                },
                sections = {
                    lualine_a = {
                        {
                            "mode",
                            fmt = function(str)
                                return str:sub(1, 1)
                            end,
                        },
                    },
                    lualine_b = { { "branch", icon = "" }, "diff" },
                    lualine_c = { { "filename", path = 1 } },
                    lualine_x = { "diagnostics" },
                    lualine_y = { "lsp_status", "location" },
                    lualine_z = {
                        function()
                            return " " .. os.date("%R")
                        end,
                    },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { "filename" },
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = {},
                },
            })
        end,
    },
}
