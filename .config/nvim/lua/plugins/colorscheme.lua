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
          gold = "#f6c177", -- more vibrant gold
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
          text = "#f0eef6", -- much brighter text
          love = "#ff5d7a", -- more saturated love
          gold = "#ffb347", -- more vibrant gold
          rose = "#f2b8c4", -- enhanced rose
          pine = "#40a4c4", -- more vibrant pine
          foam = "#a8e6cf", -- brighter foam
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

        -- Enhanced UI elements
        Normal = { fg = "text", bg = "base" },
        NormalFloat = { fg = "text", bg = "surface" },
        FloatBorder = { fg = "highlight_high", bg = "surface" },
        CursorLine = { bg = "highlight_med" }, -- More vibrant cursor line
        Visual = { bg = "rose" }, -- More vibrant visual selection, keeps original text color
        VisualNOS = { bg = "iris" }, -- Visual selection (not owning selection)
        Search = { fg = "base", bg = "gold" },
        IncSearch = { fg = "base", bg = "love" },

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
        ["@parameter"] = { fg = "iris", italic = true },
        ["@property"] = { fg = "foam" },
        ["@string"] = { fg = "gold" },
        ["@number"] = { fg = "iris", bold = true },
        ["@boolean"] = { fg = "love", bold = true },
        ["@type"] = { fg = "foam", bold = true },
        ["@type.builtin"] = { fg = "love", bold = true },
        ["@constructor"] = { fg = "gold", bold = true },
        ["@tag"] = { fg = "foam", bold = true },
        ["@tag.attribute"] = { fg = "iris" },
        ["@tag.delimiter"] = { fg = "subtle" },
      },

      before_highlight = function(group, highlight, palette)
        -- Enhance contrast for certain groups
        if group == "StatusLine" then
          highlight.bg = palette.overlay
          highlight.fg = palette.text
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
            b = { fg = rose_pine.rose, bg = rose_pine.overlay },
            c = { fg = rose_pine.text, bg = rose_pine.surface },
          },
          insert = {
            a = { fg = rose_pine.base, bg = rose_pine.foam, gui = "bold" },
            b = { fg = rose_pine.foam, bg = rose_pine.overlay },
            c = { fg = rose_pine.text, bg = rose_pine.surface },
          },
          visual = {
            a = { fg = rose_pine.base, bg = rose_pine.iris, gui = "bold" },
            b = { fg = rose_pine.iris, bg = rose_pine.overlay },
            c = { fg = rose_pine.text, bg = rose_pine.surface },
          },
          replace = {
            a = { fg = rose_pine.base, bg = rose_pine.love, gui = "bold" },
            b = { fg = rose_pine.love, bg = rose_pine.overlay },
            c = { fg = rose_pine.text, bg = rose_pine.surface },
          },
          command = {
            a = { fg = rose_pine.base, bg = rose_pine.pine, gui = "bold" },
            b = { fg = rose_pine.pine, bg = rose_pine.overlay },
            c = { fg = rose_pine.text, bg = rose_pine.surface },
          },
          inactive = {
            a = { fg = rose_pine.muted, bg = rose_pine.base },
            b = { fg = rose_pine.muted, bg = rose_pine.base },
            c = { fg = rose_pine.muted, bg = rose_pine.base },
          },
        }

        opts.options = opts.options or {}
        opts.options.theme = vibrant_rose_pine
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
