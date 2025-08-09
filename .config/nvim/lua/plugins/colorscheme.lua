return {
    -- tokyonight
    -- add rose-pine
    {
        "rose-pine/neovim",
        name = "rose-pine",
        opts = {
            variant = "auto", -- auto, main, moon, or dawn
            dark_variant = "moon", -- using moon for darker base and more contrast
            dim_inactive_windows = true, -- adds contrast between active/inactive windows
            extend_background_behind_borders = true,

            enable = {
                terminal = true,
                legacy_highlights = true, -- Improve compatibility for previous versions of Neovim
                migrations = true, -- Handle deprecated options automatically
            },

            styles = {
                bold = true,
                italic = true,
                transparency = true, -- Enable transparency support
            },

            groups = {
                border = "highlight_high", -- more vibrant borders
                link = "iris",
                panel = "base", -- darker panels for more contrast

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
                    h1 = "love", -- more vibrant headings
                    h2 = "rose",
                    h3 = "iris",
                    h4 = "gold",
                    h5 = "foam",
                    h6 = "pine",
                },
            },

            palette = {
                -- Enhanced palette for more vibrant colors and contrast
                main = {
                    base = "#191724", -- darker base
                    surface = "#1f1d2e", -- darker surface
                    overlay = "#26233a", -- more contrast
                    muted = "#6e6a86", -- enhanced muted
                    subtle = "#908caa", -- brighter subtle
                    text = "#e0def4", -- brighter text
                    love = "#eb6f92", -- more vibrant love
                    gold = "#fac75a", -- more vibrant gold
                    rose = "#ebbcba", -- enhanced rose
                    pine = "#31748f", -- more vibrant pine
                    foam = "#9ccfd8", -- brighter foam
                    iris = "#c4a7e7", -- more vibrant iris
                    highlight_low = "#21202e",
                    highlight_med = "#403d52",
                    highlight_high = "#524f67", -- for more contrast
                },
                moon = {
                    base = "#0f0e1a", -- much darker base for maximum contrast
                    surface = "#16141f", -- darker surface
                    overlay = "#1e1c2a", -- enhanced overlay
                    muted = "#6e6a86", -- same muted
                    subtle = "#a8a5c0", -- brighter subtle
                    text = "#e0def4", -- much brighter text
                    love = "#ff5d7a", -- more saturated love
                    gold = "#ffb347", -- more vibrant gold
                    rose = "#f5a6b6", -- enhanced rose
                    pine = "#40a4c4", -- more vibrant pine
                    foam = "#66deb2", -- brighter foam
                    iris = "#d4a7ff", -- more vibrant iris
                    highlight_low = "#1a1825",
                    highlight_med = "#2a2837",
                    highlight_high = "#3a3649", -- enhanced highlights
                },
            },

            highlight_groups = {
                -- Enhanced contrast for syntax highlighting
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

                -- Enhanced UI elements - REMOVED bg settings for transparency
                Normal = { fg = "text" }, -- Removed bg = "base" for transparency
                NormalFloat = { fg = "text" }, -- Transparent float windows
                FloatBorder = { fg = "highlight_high" },
                CursorLine = { bg = "highlight_med" }, -- More vibrant cursor line
                Visual = { bg = "rose" }, -- More vibrant visual selection, keeps original text color
                VisualNOS = { bg = "iris" }, -- Visual selection (not owning selection)
                Search = { fg = "base", bg = "gold" },
                IncSearch = { fg = "base", bg = "love" },

                -- Additional transparency-friendly highlights
                SignColumn = { fg = "text" }, -- Remove background from sign column
                EndOfBuffer = { fg = "muted" }, -- Remove background from end of buffer
                VertSplit = { fg = "highlight_high" }, -- Transparent window splits
                WinSeparator = { fg = "highlight_high" }, -- Transparent window separators

                -- Enhanced active/inactive window distinction
                NormalNC = { fg = "muted" }, -- Inactive windows have dimmed text
                CursorLineNr = { fg = "rose", bold = true }, -- Active window line number
                LineNr = { fg = "subtle" }, -- Regular line numbers
                LineNrAbove = { fg = "muted" }, -- Line numbers above cursor (inactive feel)
                LineNrBelow = { fg = "muted" }, -- Line numbers below cursor (inactive feel)

                -- More vibrant LSP and diagnostic highlights
                DiagnosticError = { fg = "love", bold = true },
                DiagnosticWarn = { fg = "gold", bold = true },
                DiagnosticInfo = { fg = "foam", bold = true },
                DiagnosticHint = { fg = "iris", bold = true },
                DiagnosticUnderlineError = { undercurl = true, sp = "love" },
                DiagnosticUnderlineWarn = { undercurl = true, sp = "gold" },
                DiagnosticUnderlineInfo = { undercurl = true, sp = "foam" },
                DiagnosticUnderlineHint = { undercurl = true, sp = "iris" },

                -- Enhanced Blink.cmp highlights with more contrast
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

                -- Enhanced Treesitter highlights
                ["@keyword"] = { fg = "pine", bold = true },
                ["@keyword.function"] = { fg = "pine", bold = true },
                ["@keyword.return"] = { fg = "pine", bold = true },
                ["@function"] = { fg = "rose", bold = true },
                ["@function.builtin"] = { fg = "love", bold = true },
                ["@method"] = { fg = "rose", bold = true },
                ["@variable"] = { fg = "text" },
                ["@variable.builtin"] = { fg = "love", italic = true },
                ["@string"] = { fg = "gold" },
                ["@number"] = { fg = "iris", bold = true },
                ["@boolean"] = { fg = "love", bold = true },
                ["@type"] = { fg = "foam", bold = true },
                ["@type.builtin"] = { fg = "love", bold = true },
                ["@constructor"] = { fg = "gold", bold = true },
                ["@tag"] = { fg = "foam", bold = true },
                ["@tag.attribute"] = { fg = "iris" },
                ["@tag.delimiter"] = { fg = "subtle" },

                -- Enhanced Treesitter highlights for better parameter/symbol differentiation
                ["@symbol"] = { fg = "iris", italic = true }, -- For symbols like :customer_name
                ["@string.special.symbol"] = { fg = "iris", italic = true }, -- Alternative for symbols
                ["@parameter"] = { fg = "foam", italic = true }, -- Function parameters
                ["@variable.parameter"] = { fg = "foam", italic = true }, -- Variable parameters
                ["@field"] = { fg = "foam" }, -- Struct/object fields
                ["@property"] = { fg = "foam" }, -- Properties
                ["@attribute"] = { fg = "rose" }, -- Attributes
                ["@constant"] = { fg = "love", bold = true }, -- Constants
                ["@constant.builtin"] = { fg = "love", bold = true }, -- Built-in constants
                ["@namespace"] = { fg = "pine", bold = true }, -- Namespaces/modules

                -- Elixir-specific highlights (if you're using Elixir)
                ["@keyword.elixir"] = { fg = "pine", bold = true },
                ["@atom.elixir"] = { fg = "iris", italic = true }, -- Atoms like :customer_name
                ["@variable.elixir"] = { fg = "text" },
                ["@function.call.elixir"] = { fg = "rose", bold = true },

                -- Additional language-specific improvements
                ["@punctuation.bracket"] = { fg = "subtle" }, -- Brackets and parentheses
                ["@punctuation.delimiter"] = { fg = "subtle" }, -- Commas, semicolons
                ["@operator"] = { fg = "text", bold = true }, -- Operators like |>
                ["@keyword.operator"] = { fg = "rose", bold = true }, -- Keyword operators

                -- Make sure these are properly differentiated
                ["@type.qualifier"] = { fg = "pine", italic = true }, -- Type qualifiers
                ["@storageclass"] = { fg = "pine", bold = true }, -- Storage classes
            },

            before_highlight = function(group, highlight, palette)
                -- Enable transparency for key background groups
                if group == "Normal" then
                    highlight.bg = "NONE" -- Make active window background transparent
                end
                if group == "NormalNC" then
                    highlight.bg = "NONE" -- Make inactive window background transparent but keep dimmed text
                    highlight.fg = palette.muted -- Ensure inactive windows are dimmed
                end
                if group == "SignColumn" then
                    highlight.bg = "NONE" -- Transparent sign column
                end
                if group == "EndOfBuffer" then
                    highlight.bg = "NONE" -- Transparent end of buffer
                end

                -- Enhance contrast for certain groups while maintaining transparency
                if group == "StatusLine" then
                    highlight.bg = palette.overlay
                    highlight.fg = palette.text
                end
                if group == "StatusLineNC" then
                    highlight.bg = palette.base
                    highlight.fg = palette.muted -- Dimmed statusline for inactive windows
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
        },
    },
    -- Enhanced lualine for rose-pine vibrancy
    {
        "nvim-lualine/lualine.nvim",
        optional = true,
        opts = function(_, opts)
            if
                vim.g.colors_name == "rose-pine"
                or vim.g.colors_name == "rose-pine-moon"
                or vim.g.colors_name == "rose-pine-main"
            then
                local rose_pine = require("rose-pine.palette")

                -- Create vibrant lualine theme
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

                opts.options = opts.options or {}
                opts.options.theme = vibrant_rose_pine
                opts.options.component_separators = { left = "", right = "" }
                opts.options.section_separators = { left = "", right = "" }
                opts.options.globalstatus = true -- Single statusline at bottom
                -- Minimal sections configuration
                opts.sections = {
                    lualine_a = {
                        {
                            "mode",
                            fmt = function(str)
                                return str:sub(1, 1)
                            end, -- Only first letter
                        },
                    },
                    lualine_b = { { "branch", icon = "" }, "diff" }, -- Empty
                    lualine_c = { { "filename", path = 1 } }, -- Just filename
                    lualine_x = { "diagnostics" }, -- Only diagnostics
                    lualine_y = { "lsp_status", "location" }, -- Empty
                    lualine_z = {
                        function()
                            return " " .. os.date("%R")
                        end,
                    },
                }

                -- ULTRA MINIMAL ALTERNATIVE (uncomment to use):
                -- opts.sections = {
                --     lualine_a = {},
                --     lualine_b = {},
                --     lualine_c = { "filename" },               -- Only filename in center
                --     lualine_x = {},
                --     lualine_y = {},
                --     lualine_z = { "location" },               -- Only location on right
                -- }
                -- Minimal inactive sections
                opts.inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { "filename" },
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = {},
                }
            end
            return opts
        end,
    },
    -- Configure LazyVim to load rose-pine-moon
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "rose-pine-moon",
        },
    },
}
