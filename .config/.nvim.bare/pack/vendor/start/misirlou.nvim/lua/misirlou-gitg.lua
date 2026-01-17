local M = {}
local config = require("misirlou.config")

local function set_highlights()
    local utilities = require("misirlou.utilities")
    local palette = require("misirlou.palette")
    local styles = config.options.styles

    local groups = {}
    for group, color in pairs(config.options.groups) do
        groups[group] = utilities.parse_color(color)
    end

    -- Override groups for des theme to match color semantics
    -- In des: rose=#de935f (orange), gold=#8ec07c (green)
    groups.warn = utilities.parse_color(palette.rose) -- orange for warnings
    groups.ok = utilities.parse_color(palette.gold) -- green for success
    groups.git_add = utilities.parse_color(palette.gold) -- green for additions

    local function make_border(fg)
        fg = utilities.parse_color(fg or groups.border)
        return {
            fg = fg,
            bg = (config.options.extend_background_behind_borders and not styles.transparency) and palette.bg or "NONE",
        }
    end

    local highlights = {}
    local legacy_highlights = {
        ["@attribute.diff"] = { fg = palette.gold },
        ["@boolean"] = { link = "Boolean" },
        ["@class"] = { fg = palette.lavender },
        ["@conditional"] = { link = "Conditional" },
        ["@field"] = { fg = palette.green },
        ["@include"] = { link = "Include" },
        ["@interface"] = { fg = palette.lavender },
        ["@macro"] = { link = "Macro" },
        ["@method"] = { fg = palette.purple },
        ["@namespace"] = { link = "Include" },
        ["@number"] = { link = "Number" },
        ["@parameter"] = { fg = palette.text },
        ["@preproc"] = { fg = palette.green },
        ["@punctuation"] = { fg = palette.text },
        ["@punctuation.bracket"] = { fg = palette.text },
        ["@punctuation.delimiter"] = { link = "@punctuation" },
        ["@punctuation.special"] = { link = "@punctuation" },
        ["@regexp"] = { link = "String" },
        ["@repeat"] = { link = "Repeat" },
        ["@storageclass"] = { link = "StorageClass" },
        ["@symbol"] = { link = "Identifier" },
        ["@text"] = { fg = palette.text },
        ["@text.danger"] = { fg = groups.error },
        ["@text.diff.add"] = { fg = groups.git_add, bg = groups.git_add, blend = 20 },
        ["@text.diff.delete"] = { fg = groups.git_delete, bg = groups.git_delete, blend = 20 },
        ["@text.emphasis"] = {},
        ["@text.environment"] = { link = "Macro" },
        ["@text.environment.name"] = { link = "Type" },
        ["@text.math"] = { link = "Special" },
        ["@text.note"] = { link = "SpecialComment" },
        ["@text.strike"] = { strikethrough = true },
        ["@text.strong"] = { bold = styles.bold },
        ["@text.title"] = { link = "Title" },
        ["@text.title.1.markdown"] = { link = "markdownH1" },
        ["@text.title.1.marker.markdown"] = { link = "markdownH1Delimiter" },
        ["@text.title.2.markdown"] = { link = "markdownH2" },
        ["@text.title.2.marker.markdown"] = { link = "markdownH2Delimiter" },
        ["@text.title.3.markdown"] = { link = "markdownH3" },
        ["@text.title.3.marker.markdown"] = { link = "markdownH3Delimiter" },
        ["@text.title.4.markdown"] = { link = "markdownH4" },
        ["@text.title.4.marker.markdown"] = { link = "markdownH4Delimiter" },
        ["@text.title.5.markdown"] = { link = "markdownH5" },
        ["@text.title.5.marker.markdown"] = { link = "markdownH5Delimiter" },
        ["@text.title.6.markdown"] = { link = "markdownH6" },
        ["@text.title.6.marker.markdown"] = { link = "markdownH6Delimiter" },
        ["@text.underline"] = { underline = true },
        ["@text.uri"] = { fg = groups.link },
        ["@text.warning"] = { fg = groups.warn },
        ["@todo"] = { link = "Todo" },

        IndentBlanklineChar = { fg = palette.muted, nocombine = true },
        IndentBlanklineSpaceChar = { fg = palette.muted, nocombine = true },
        IndentBlanklineSpaceCharBlankline = { fg = palette.muted, nocombine = true },
    }
    local default_highlights = {
        ColorColumn = { bg = palette.base },
        Conceal = { bg = "NONE" },
        CurSearch = { fg = palette.base, bg = palette.green },
        Cursor = { fg = palette.text, bg = palette.highlight_high },
        CursorColumn = { bg = palette.bg },
        CursorLine = { bg = palette.surface },
        CursorLineNr = { fg = palette.text, bg = palette.bg, bold = styles.bold },
        DiffAdd = { bg = groups.git_add, blend = 20 },
        DiffChange = { bg = groups.git_change, blend = 20 },
        DiffDelete = { bg = groups.git_delete, blend = 20 },
        DiffText = { bg = groups.git_text, blend = 40 },
        diffAdded = { link = "DiffAdd" },
        diffChanged = { link = "DiffChange" },
        diffRemoved = { link = "DiffDelete" },
        Directory = { fg = palette.lavender, bold = styles.bold },
        EndOfBuffer = { fg = palette.muted, bg = palette.bg },
        ErrorMsg = { fg = groups.error, bold = styles.bold },
        FloatBorder = { fg = palette.text, bg = palette.bg },
        FloatTitle = { fg = palette.text, bg = palette.bg },
        FoldColumn = { fg = palette.muted, bg = palette.bg },
        Folded = { fg = palette.text, bg = palette.bg },
        IncSearch = { fg = palette.base, bg = palette.green },
        LineNr = { fg = palette.muted, bg = palette.bg },
        MatchParen = { fg = palette.lavender, bg = palette.lavender, blend = 25 },
        ModeMsg = { fg = palette.subtle },
        MoreMsg = { fg = palette.purple },
        NonText = { fg = palette.muted },
        Normal = { fg = palette.text, bg = palette.bg },
        NormalFloat = { fg = palette.text, bg = palette.bg },
        NormalNC = { fg = palette.text, bg = palette.bg },
        NvimInternalError = { link = "ErrorMsg" },
        Pmenu = { fg = palette.subtle, bg = palette.bg },
        PmenuExtra = { fg = palette.muted, bg = palette.bg },
        PmenuExtraSel = { fg = palette.subtle, bg = palette.highlight_high },
        PmenuKind = { fg = palette.lavender, bg = palette.bg },
        PmenuKindSel = { fg = palette.subtle, bg = palette.highlight_high },
        PmenuMatch = { fg = palette.green },
        PmenuMatchSel = { fg = palette.green, bg = palette.highlight_high },
        PmenuSbar = { bg = palette.bg },
        PmenuSel = { fg = palette.text, bg = palette.highlight_high },
        PmenuThumb = { bg = palette.muted },
        Question = { fg = palette.gold },
        QuickFixLine = { fg = palette.lavender },
        RedrawDebugClear = { fg = palette.base, bg = palette.gold },
        RedrawDebugComposed = { fg = palette.base, bg = palette.blue },
        RedrawDebugRecompose = { fg = palette.base, bg = palette.red },
        Search = { fg = palette.base, bg = palette.lavender, blend = 80 },
        SignColumn = { fg = palette.text, bg = palette.bg },
        SpecialKey = { fg = palette.lavender },
        SpellBad = { sp = palette.subtle, undercurl = true },
        SpellCap = { sp = palette.subtle, undercurl = true },
        SpellLocal = { sp = palette.subtle, undercurl = true },
        SpellRare = { sp = palette.subtle, undercurl = true },
        StatusLine = { fg = palette.subtle, bg = palette.base },
        StatusLineNC = { fg = palette.muted, bg = palette.base, blend = 60 },
        StatusLineTerm = { fg = palette.base, bg = palette.blue },
        StatusLineTermNC = { fg = palette.base, bg = palette.blue, blend = 60 },
        Substitute = { link = "IncSearch" },
        TabLine = { fg = palette.subtle, bg = palette.bg },
        TabLineFill = { bg = palette.bg },
        TabLineSel = { fg = palette.text, bg = palette.highlight_low, bold = styles.bold },
        Title = { fg = palette.lavender, bold = styles.bold },
        VertSplit = { fg = groups.border },
        Visual = { bg = palette.green, blend = 38 },
        YankHighlight = { fg = palette.text, bg = palette.green, blend = 50 },
        WarningMsg = { fg = groups.warn, bold = styles.bold },
        WildMenu = { link = "IncSearch" },
        WinBar = { fg = palette.subtle, bg = palette.bg },
        WinBarNC = { fg = palette.muted, bg = palette.bg, blend = 60 },
        WinSeparator = { fg = groups.border },

        DiagnosticError = { fg = groups.error },
        DiagnosticHint = { fg = groups.hint },
        DiagnosticInfo = { fg = groups.info },
        DiagnosticOk = { fg = groups.ok },
        DiagnosticWarn = { fg = groups.warn },
        DiagnosticDefaultError = { link = "DiagnosticError" },
        DiagnosticDefaultHint = { link = "DiagnosticHint" },
        DiagnosticDefaultInfo = { link = "DiagnosticInfo" },
        DiagnosticDefaultOk = { link = "DiagnosticOk" },
        DiagnosticDefaultWarn = { link = "DiagnosticWarn" },
        DiagnosticFloatingError = { link = "DiagnosticError" },
        DiagnosticFloatingHint = { link = "DiagnosticHint" },
        DiagnosticFloatingInfo = { link = "DiagnosticInfo" },
        DiagnosticFloatingOk = { link = "DiagnosticOk" },
        DiagnosticFloatingWarn = { link = "DiagnosticWarn" },
        DiagnosticSignError = { link = "DiagnosticError" },
        DiagnosticSignHint = { link = "DiagnosticHint" },
        DiagnosticSignInfo = { link = "DiagnosticInfo" },
        DiagnosticSignOk = { link = "DiagnosticOk" },
        DiagnosticSignWarn = { link = "DiagnosticWarn" },
        DiagnosticUnderlineError = { sp = groups.error, undercurl = true },
        DiagnosticUnderlineHint = { sp = groups.hint, undercurl = true },
        DiagnosticUnderlineInfo = { sp = groups.info, undercurl = true },
        DiagnosticUnderlineOk = { sp = groups.ok, undercurl = true },
        DiagnosticUnderlineWarn = { sp = groups.warn, undercurl = true },
        DiagnosticVirtualTextError = { fg = groups.error, bg = groups.error, blend = 10 },
        DiagnosticVirtualTextHint = { fg = groups.hint, bg = groups.hint, blend = 10 },
        DiagnosticVirtualTextInfo = { fg = groups.info, bg = groups.info, blend = 10 },
        DiagnosticVirtualTextOk = { fg = groups.ok, bg = groups.ok, blend = 10 },
        DiagnosticVirtualTextWarn = { fg = groups.warn, bg = groups.warn, blend = 10 },

        Boolean = { fg = palette.green },
        Character = { fg = palette.green },
        Comment = { fg = palette.subtle, italic = styles.italic },
        Conditional = { fg = palette.blue },
        Constant = { fg = palette.green },
        Debug = { fg = palette.rose },
        Define = { fg = palette.purple },
        Delimiter = { fg = palette.text },
        Error = { fg = palette.red },
        Exception = { fg = palette.blue },
        Float = { fg = palette.green },
        Function = { fg = palette.purple },
        Identifier = { fg = palette.text },
        Include = { fg = palette.blue },
        Keyword = { fg = palette.blue },
        Label = { fg = palette.lavender },
        LspCodeLens = { fg = palette.subtle },
        LspCodeLensSeparator = { fg = palette.muted },
        LspInlayHint = { fg = palette.muted, bg = palette.muted, blend = 10 },
        LspReferenceRead = { bold = true },
        LspReferenceText = { bold = true },
        LspReferenceWrite = { bold = true },
        Macro = { fg = palette.green },
        Number = { fg = palette.green },
        Operator = { fg = palette.text },
        PreCondit = { fg = palette.purple },
        PreProc = { link = "PreCondit" },
        Repeat = { fg = palette.blue },
        Special = { fg = palette.purple },
        SpecialChar = { link = "Special" },
        SpecialComment = { fg = palette.purple },
        Statement = { fg = palette.blue, bold = styles.bold },
        StorageClass = { fg = palette.lavender },
        String = { fg = palette.lavender },
        Structure = { fg = palette.lavender },
        Tag = { fg = palette.text },
        Todo = { fg = palette.rose, bg = palette.rose, blend = 20 },
        Type = { fg = palette.lavender },
        TypeDef = { link = "Type" },
        Underlined = { fg = palette.purple, underline = true },

        healthError = { fg = groups.error },
        healthSuccess = { fg = groups.info },
        healthWarning = { fg = groups.warn },

        htmlArg = { fg = palette.purple },
        htmlBold = { bold = styles.bold },
        htmlEndTag = { fg = palette.text },
        htmlH1 = { link = "markdownH1" },
        htmlH2 = { link = "markdownH2" },
        htmlH3 = { link = "markdownH3" },
        htmlH4 = { link = "markdownH4" },
        htmlH5 = { link = "markdownH5" },
        htmlItalic = {},
        htmlLink = { link = "markdownUrl" },
        htmlTag = { fg = palette.text },
        htmlTagN = { fg = palette.text },
        htmlTagName = { fg = palette.text },

        markdownDelimiter = { fg = palette.text },
        markdownH1 = { fg = groups.h1, bold = styles.bold },
        markdownH1Delimiter = { link = "markdownH1" },
        markdownH2 = { fg = groups.h2, bold = styles.bold },
        markdownH2Delimiter = { link = "markdownH2" },
        markdownH3 = { fg = groups.h3, bold = styles.bold },
        markdownH3Delimiter = { link = "markdownH3" },
        markdownH4 = { fg = groups.h4, bold = styles.bold },
        markdownH4Delimiter = { link = "markdownH4" },
        markdownH5 = { fg = groups.h5, bold = styles.bold },
        markdownH5Delimiter = { link = "markdownH5" },
        markdownH6 = { fg = groups.h6, bold = styles.bold },
        markdownH6Delimiter = { link = "markdownH6" },
        markdownLinkText = { link = "markdownUrl" },
        markdownUrl = { fg = groups.link, sp = groups.link, underline = true },

        mkdCode = { fg = palette.lavender },
        mkdCodeDelimiter = { fg = palette.rose },
        mkdCodeEnd = { fg = palette.lavender },
        mkdCodeStart = { fg = palette.lavender },
        mkdFootnotes = { fg = palette.lavender },
        mkdID = { fg = palette.lavender, underline = true },
        mkdInlineURL = { link = "markdownUrl" },
        mkdLink = { link = "markdownUrl" },
        mkdLinkDef = { link = "markdownUrl" },
        mkdListItemLine = { fg = palette.text },
        mkdRule = { fg = palette.subtle },
        mkdURL = { link = "markdownUrl" },

        ["@variable"] = { fg = palette.text },
        ["@variable.builtin"] = { fg = palette.red, bold = styles.bold },
        ["@variable.parameter"] = { fg = palette.text },
        ["@variable.parameter.builtin"] = { fg = palette.text, bold = styles.bold },
        ["@variable.member"] = { fg = palette.lavender },

        ["@constant"] = { fg = palette.green },
        ["@constant.builtin"] = { fg = palette.green, bold = styles.bold },
        ["@constant.macro"] = { fg = palette.green },

        ["@module"] = { fg = palette.text },
        ["@module.builtin"] = { fg = palette.text, bold = styles.bold },
        ["@label"] = { link = "Label" },

        ["@string"] = { link = "String" },
        ["@string.regexp"] = { fg = palette.purple },
        ["@string.escape"] = { fg = palette.blue },
        ["@string.special"] = { link = "String" },
        ["@string.special.symbol"] = { link = "Identifier" },
        ["@string.special.url"] = { fg = groups.link },

        ["@character"] = { link = "Character" },
        ["@character.special"] = { link = "Character" },

        ["@boolean"] = { link = "Boolean" },
        ["@number"] = { link = "Number" },
        ["@number.float"] = { link = "Number" },
        ["@float"] = { link = "Number" },

        ["@type"] = { fg = palette.red },
        ["@type.builtin"] = { fg = palette.red, bold = styles.bold },

        ["@attribute"] = { fg = palette.purple },
        ["@attribute.builtin"] = { fg = palette.purple, bold = styles.bold },
        ["@property"] = { fg = palette.lavender },

        ["@function"] = { fg = palette.purple },
        ["@function.call"] = { fg = palette.green },
        ["@function.builtin"] = { fg = palette.green, bold = styles.bold },
        ["@function.macro"] = { link = "Function" },

        ["@function.method"] = { fg = palette.purple },
        ["@function.method.call"] = { fg = palette.green },

        ["@constructor"] = { fg = palette.lavender },
        ["@operator"] = { link = "Operator" },

        ["@keyword"] = { link = "Keyword" },
        ["@keyword.operator"] = { fg = palette.lavender },
        ["@keyword.import"] = { fg = palette.blue },
        ["@keyword.storage"] = { fg = palette.lavender },
        ["@keyword.repeat"] = { fg = palette.blue },
        ["@keyword.return"] = { fg = palette.blue },
        ["@keyword.debug"] = { fg = palette.rose },
        ["@keyword.exception"] = { fg = palette.blue },

        ["@keyword.conditional"] = { fg = palette.blue },
        ["@keyword.conditional.ternary"] = { fg = palette.blue },

        ["@keyword.directive"] = { fg = palette.purple },
        ["@keyword.directive.define"] = { fg = palette.purple },

        ["@punctuation"] = { fg = palette.text },
        ["@punctuation.delimiter"] = { link = "@punctuation" },
        ["@punctuation.bracket"] = { link = "@punctuation" },
        ["@punctuation.special"] = { link = "@punctuation" },

        ["@comment"] = { link = "Comment" },

        ["@comment.error"] = { fg = groups.error },
        ["@comment.warning"] = { fg = groups.warn },
        ["@comment.todo"] = { fg = groups.todo, bg = groups.todo, blend = 15 },
        ["@comment.hint"] = { fg = groups.hint, bg = groups.hint, blend = 15 },
        ["@comment.info"] = { fg = groups.info, bg = groups.info, blend = 15 },
        ["@comment.note"] = { fg = groups.note, bg = groups.note, blend = 15 },

        -- YAML-specific Treesitter overrides for better contrast
        ["@property.yaml"] = { fg = palette.purple },
        ["@string.yaml"] = { fg = palette.lavender },
        ["@string.escape.yaml"] = { fg = palette.blue },
        ["@number.yaml"] = { fg = palette.gold },
        ["@boolean.yaml"] = { fg = palette.rose },
        ["@constant.builtin.yaml"] = { fg = palette.red },
        ["@label.yaml"] = { fg = palette.blue },
        ["@type.yaml"] = { fg = palette.purple },
        ["@keyword.directive.yaml"] = { fg = palette.purple },

        ["@markup.strong"] = { bold = styles.bold },
        ["@markup.italic"] = {},
        ["@markup.strikethrough"] = { strikethrough = true },
        ["@markup.underline"] = { underline = true },

        ["@markup.heading"] = { fg = palette.lavender, bold = styles.bold },

        ["@markup.quote"] = { fg = palette.text },
        ["@markup.math"] = { link = "Special" },
        ["@markup.environment"] = { link = "Macro" },
        ["@markup.environment.name"] = { link = "@type" },

        ["@markup.link.markdown_inline"] = { fg = palette.subtle },
        ["@markup.link.label.markdown_inline"] = { fg = palette.lavender },
        ["@markup.link.url"] = { fg = groups.link },

        ["@markup.raw.delimiter.markdown"] = { fg = palette.subtle },

        ["@markup.list"] = { fg = palette.blue },
        ["@markup.list.checked"] = { fg = palette.lavender, bg = palette.lavender, blend = 10 },
        ["@markup.list.unchecked"] = { fg = palette.text },

        ["@markup.heading.1.markdown"] = { link = "markdownH1" },
        ["@markup.heading.2.markdown"] = { link = "markdownH2" },
        ["@markup.heading.3.markdown"] = { link = "markdownH3" },
        ["@markup.heading.4.markdown"] = { link = "markdownH4" },
        ["@markup.heading.5.markdown"] = { link = "markdownH5" },
        ["@markup.heading.6.markdown"] = { link = "markdownH6" },
        ["@markup.heading.1.marker.markdown"] = { link = "markdownH1Delimiter" },
        ["@markup.heading.2.marker.markdown"] = { link = "markdownH2Delimiter" },
        ["@markup.heading.3.marker.markdown"] = { link = "markdownH3Delimiter" },
        ["@markup.heading.4.marker.markdown"] = { link = "markdownH4Delimiter" },
        ["@markup.heading.5.marker.markdown"] = { link = "markdownH5Delimiter" },
        ["@markup.heading.6.marker.markdown"] = { link = "markdownH6Delimiter" },

        ["@diff.plus"] = { fg = groups.git_add, bg = groups.git_add, blend = 20 },
        ["@diff.minus"] = { fg = groups.git_delete, bg = groups.git_delete, blend = 20 },
        ["@diff.delta"] = { bg = groups.git_change, blend = 20 },

        ["@tag"] = { link = "Tag" },
        ["@tag.attribute"] = { fg = palette.purple },
        ["@tag.delimiter"] = { fg = palette.text },

        ["@conceal"] = { link = "Conceal" },
        ["@conceal.markdown"] = { fg = palette.subtle },

        ["@lsp.type.comment"] = {},
        ["@lsp.type.comment.c"] = { link = "@comment" },
        ["@lsp.type.comment.cpp"] = { link = "@comment" },
        ["@lsp.type.enum"] = { link = "@type" },
        ["@lsp.type.interface"] = { link = "@interface" },
        ["@lsp.type.keyword"] = { link = "@keyword" },
        ["@lsp.type.namespace"] = { link = "@namespace" },
        ["@lsp.type.namespace.python"] = { link = "@variable" },
        ["@lsp.type.parameter"] = { link = "@parameter" },
        ["@lsp.type.property"] = { link = "@property" },
        ["@lsp.type.variable"] = {},
        ["@lsp.type.variable.svelte"] = { link = "@variable" },
        ["@lsp.typemod.function.defaultLibrary"] = { link = "@function.builtin" },
        ["@lsp.typemod.operator.injected"] = { link = "@operator" },
        ["@lsp.typemod.string.injected"] = { link = "@string" },
        ["@lsp.typemod.variable.constant"] = { link = "@constant" },
        ["@lsp.typemod.variable.defaultLibrary"] = { link = "@variable.builtin" },
        ["@lsp.typemod.variable.injected"] = { link = "@variable" },

        BufferCurrent = { fg = palette.text, bg = palette.highlight_low },
        BufferCurrentIndex = { fg = palette.text, bg = palette.highlight_low },
        BufferCurrentMod = { fg = palette.lavender, bg = palette.highlight_low },
        BufferCurrentSign = { fg = palette.subtle, bg = palette.highlight_low },
        BufferCurrentTarget = { fg = palette.gold, bg = palette.highlight_low },
        BufferInactive = { fg = palette.subtle },
        BufferInactiveIndex = { fg = palette.subtle },
        BufferInactiveMod = { fg = palette.lavender },
        BufferInactiveSign = { fg = palette.muted },
        BufferInactiveTarget = { fg = palette.gold },
        BufferTabpageFill = { fg = "NONE", bg = "NONE" },
        BufferVisible = { fg = palette.subtle },
        BufferVisibleIndex = { fg = palette.subtle },
        BufferVisibleMod = { fg = palette.lavender },
        BufferVisibleSign = { fg = palette.muted },
        BufferVisibleTarget = { fg = palette.gold },

        GitSignsAdd = { fg = groups.git_add, bg = "NONE" },
        GitSignsChange = { fg = groups.git_change, bg = "NONE" },
        GitSignsDelete = { fg = groups.git_delete, bg = "NONE" },
        SignAdd = { fg = groups.git_add, bg = "NONE" },
        SignChange = { fg = groups.git_change, bg = "NONE" },
        SignDelete = { fg = groups.git_delete, bg = "NONE" },

        ModesCopy = { bg = palette.gold },
        ModesDelete = { bg = palette.red },
        ModesFormat = { bg = palette.rose },
        ModesInsert = { bg = palette.lavender },
        ModesReplace = { bg = palette.blue },
        ModesVisual = { bg = palette.purple },

        NvimTreeEmptyFolderName = { fg = palette.muted },
        NvimTreeFileDeleted = { fg = groups.git_delete },
        NvimTreeFileDirty = { fg = groups.git_dirty },
        NvimTreeFileMerge = { fg = groups.git_merge },
        NvimTreeFileNew = { fg = palette.lavender },
        NvimTreeFileRenamed = { fg = groups.git_rename },
        NvimTreeFileStaged = { fg = groups.git_stage },
        NvimTreeFolderIcon = { fg = palette.subtle },
        NvimTreeFolderName = { fg = palette.lavender },
        NvimTreeGitDeleted = { fg = groups.git_delete },
        NvimTreeGitDirty = { fg = groups.git_dirty },
        NvimTreeGitIgnored = { fg = groups.git_ignore },
        NvimTreeGitMerge = { fg = groups.git_merge },
        NvimTreeGitNew = { fg = groups.git_add },
        NvimTreeGitRenamed = { fg = groups.git_rename },
        NvimTreeGitStaged = { fg = groups.git_stage },
        NvimTreeImageFile = { fg = palette.text },
        NvimTreeNormal = { link = "Normal" },
        NvimTreeOpenedFile = { fg = palette.text, bg = palette.highlight_low },
        NvimTreeOpenedFolderName = { link = "NvimTreeFolderName" },
        NvimTreeRootFolder = { fg = palette.lavender, bold = styles.bold },
        NvimTreeSpecialFile = { link = "NvimTreeNormal" },
        NvimTreeWindowPicker = { link = "StatusLineTerm" },

        NeotestAdapterName = { fg = palette.purple },
        NeotestBorder = { fg = palette.text },
        NeotestDir = { fg = palette.lavender },
        NeotestExpandMarker = { fg = palette.highlight_med },
        NeotestFailed = { fg = palette.red },
        NeotestFile = { fg = palette.text },
        NeotestFocused = { fg = palette.gold, bg = palette.highlight_med },
        NeotestIndent = { fg = palette.highlight_med },
        NeotestMarked = { fg = palette.rose, bold = styles.bold },
        NeotestNamespace = { fg = palette.gold },
        NeotestPassed = { fg = palette.blue },
        NeotestRunning = { fg = palette.gold },
        NeotestWinSelect = { fg = palette.muted },
        NeotestSkipped = { fg = palette.subtle },
        NeotestTarget = { fg = palette.red },
        NeotestTest = { fg = palette.gold },
        NeotestUnknown = { fg = palette.subtle },
        NeotestWatching = { fg = palette.purple },

        NeoTreeGitAdded = { fg = groups.git_add },
        NeoTreeGitConflict = { fg = groups.git_merge },
        NeoTreeGitDeleted = { fg = groups.git_delete },
        NeoTreeGitIgnored = { fg = groups.git_ignore },
        NeoTreeGitModified = { fg = groups.git_dirty },
        NeoTreeGitRenamed = { fg = groups.git_rename },
        NeoTreeGitUntracked = { fg = groups.git_untracked },
        NeoTreeTabActive = { fg = palette.text, bg = palette.highlight_low },
        NeoTreeTabInactive = { fg = palette.subtle },
        NeoTreeTabSeparatorActive = { link = "WinSeparator" },
        NeoTreeTabSeparatorInactive = { link = "WinSeparator" },
        NeoTreeTitleBar = { link = "StatusLineTerm" },

        FlashLabel = { fg = palette.base, bg = palette.red },

        WhichKey = { fg = palette.purple },
        WhichKeyBorder = make_border(),
        WhichKeyDesc = { fg = palette.gold },
        WhichKeyFloat = { bg = palette.bg },
        WhichKeyGroup = { fg = palette.lavender },
        WhichKeyIcon = { fg = palette.blue },
        WhichKeyIconAzure = { fg = palette.blue },
        WhichKeyIconBlue = { fg = palette.blue },
        WhichKeyIconCyan = { fg = palette.lavender },
        WhichKeyIconGreen = { fg = palette.green },
        WhichKeyIconGrey = { fg = palette.subtle },
        WhichKeyIconOrange = { fg = palette.rose },
        WhichKeyIconPurple = { fg = palette.purple },
        WhichKeyIconRed = { fg = palette.red },
        WhichKeyIconYellow = { fg = palette.gold },
        WhichKeyNormal = { link = "NormalFloat" },
        WhichKeySeparator = { fg = palette.subtle },
        WhichKeyTitle = { link = "FloatTitle" },
        WhichKeyValue = { fg = palette.rose },

        IblIndent = { fg = palette.overlay },
        IblScope = { fg = palette.lavender },
        IblWhitespace = { fg = palette.overlay },

        CmpItemAbbr = { fg = palette.subtle },
        CmpItemAbbrDeprecated = { fg = palette.subtle, strikethrough = true },
        CmpItemAbbrMatch = { fg = palette.text, bold = styles.bold },
        CmpItemAbbrMatchFuzzy = { fg = palette.text, bold = styles.bold },
        CmpItemKind = { fg = palette.subtle },
        CmpItemKindClass = { link = "StorageClass" },
        CmpItemKindFunction = { link = "Function" },
        CmpItemKindInterface = { link = "Type" },
        CmpItemKindMethod = { link = "PreProc" },
        CmpItemKindSnippet = { link = "String" },
        CmpItemKindVariable = { link = "Identifier" },

        NeogitChangeAdded = { fg = groups.git_add, bold = styles.bold },
        NeogitChangeBothModified = { fg = groups.git_change, bold = styles.bold },
        NeogitChangeCopied = { fg = groups.git_untracked, bold = styles.bold },
        NeogitChangeDeleted = { fg = groups.git_delete, bold = styles.bold },
        NeogitChangeModified = { fg = groups.git_change, bold = styles.bold },
        NeogitChangeNewFile = { fg = groups.git_stage, bold = styles.bold },
        NeogitChangeRenamed = { fg = groups.git_rename, bold = styles.bold },
        NeogitChangeUpdated = { fg = groups.git_change, bold = styles.bold },
        NeogitDiffAddHighlight = { link = "DiffAdd" },
        NeogitDiffContextHighlight = { bg = palette.bg },
        NeogitDiffDeleteHighlight = { link = "DiffDelete" },
        NeogitFilePath = { fg = palette.lavender },
        NeogitHunkHeader = { bg = palette.bg },
        NeogitHunkHeaderHighlight = { bg = palette.bg },

        VimwikiHR = { fg = palette.subtle },
        VimwikiHeader1 = { link = "markdownH1" },
        VimwikiHeader2 = { link = "markdownH2" },
        VimwikiHeader3 = { link = "markdownH3" },
        VimwikiHeader4 = { link = "markdownH4" },
        VimwikiHeader5 = { link = "markdownH5" },
        VimwikiHeader6 = { link = "markdownH6" },
        VimwikiHeaderChar = { fg = palette.subtle },
        VimwikiLink = { link = "markdownUrl" },
        VimwikiList = { fg = palette.purple },
        VimwikiNoExistsLink = { fg = palette.red },

        NeorgHeading1Prefix = { link = "markdownH1Delimiter" },
        NeorgHeading1Title = { link = "markdownH1" },
        NeorgHeading2Prefix = { link = "markdownH2Delimiter" },
        NeorgHeading2Title = { link = "markdownH2" },
        NeorgHeading3Prefix = { link = "markdownH3Delimiter" },
        NeorgHeading3Title = { link = "markdownH3" },
        NeorgHeading4Prefix = { link = "markdownH4Delimiter" },
        NeorgHeading4Title = { link = "markdownH4" },
        NeorgHeading5Prefix = { link = "markdownH5Delimiter" },
        NeorgHeading5Title = { link = "markdownH5" },
        NeorgHeading6Prefix = { link = "markdownH6Delimiter" },
        NeorgHeading6Title = { link = "markdownH6" },
        NeorgMarkerTitle = { fg = palette.lavender, bold = styles.bold },

        DefinitionCount = { fg = palette.rose },
        DefinitionIcon = { fg = palette.rose },
        DefinitionPreviewTitle = { fg = palette.rose, bold = styles.bold },
        LspFloatWinBorder = make_border(),
        LspFloatWinNormal = { bg = palette.bg },
        LspSagaAutoPreview = { fg = palette.subtle },
        LspSagaCodeActionBorder = make_border("text"),
        LspSagaCodeActionContent = { fg = palette.lavender },
        LspSagaCodeActionTitle = { fg = palette.gold, bold = styles.bold },
        LspSagaCodeActionTruncateLine = { link = "LspSagaCodeActionBorder" },
        LspSagaDefPreviewBorder = make_border(),
        LspSagaDiagnosticBorder = make_border("text"),
        LspSagaDiagnosticHeader = { fg = palette.lavender, bold = styles.bold },
        LspSagaDiagnosticTruncateLine = { link = "LspSagaDiagnosticBorder" },
        LspSagaDocTruncateLine = { link = "LspSagaHoverBorder" },
        LspSagaFinderSelection = { fg = palette.gold },
        LspSagaHoverBorder = { link = "LspFloatWinBorder" },
        LspSagaLspFinderBorder = { link = "LspFloatWinBorder" },
        LspSagaRenameBorder = make_border("text"),
        LspSagaRenamePromptPrefix = { fg = palette.red },
        LspSagaShTruncateLine = { link = "LspSagaSignatureHelpBorder" },
        LspSagaSignatureHelpBorder = make_border("text"),
        ReferencesCount = { fg = palette.rose },
        ReferencesIcon = { fg = palette.rose },
        SagaShadow = { bg = palette.bg },
        TargetWord = { fg = palette.purple },

        LspSignatureActiveParameter = { bg = palette.highlight_low },

        PounceAccept = { fg = palette.red, bg = palette.red, blend = 20 },
        PounceAcceptBest = { fg = palette.gold, bg = palette.gold, blend = 20 },
        PounceGap = { link = "Search" },
        PounceMatch = { link = "Search" },

        LeapLabelPrimary = { link = "IncSearch" },
        LeapLabelSecondary = { link = "StatusLineTerm" },
        LeapMatch = { link = "MatchParen" },

        HopNextKey = { fg = palette.red, bg = palette.red, blend = 20 },
        HopNextKey1 = { fg = palette.lavender, bg = palette.lavender, blend = 20 },
        HopNextKey2 = { fg = palette.blue, bg = palette.blue, blend = 20 },
        HopUnmatched = { fg = palette.muted },

        TelescopeBorder = make_border(),
        TelescopeMatching = { fg = palette.rose },
        TelescopeNormal = { link = "NormalFloat" },
        TelescopePromptNormal = { link = "TelescopeNormal" },
        TelescopePromptPrefix = { fg = palette.subtle },
        TelescopeSelection = { fg = palette.text, bg = palette.highlight_low },
        TelescopeSelectionCaret = { fg = palette.rose, bg = palette.highlight_low },
        TelescopeTitle = { fg = palette.lavender, bold = styles.bold },

        FzfLuaBorder = make_border(),
        FzfLuaBufFlagAlt = { fg = palette.subtle },
        FzfLuaBufFlagCur = { fg = palette.subtle },
        FzfLuaCursorLine = { fg = palette.text, bg = palette.highlight_low },
        FzfLuaFilePart = { fg = palette.text },
        FzfLuaHeaderBind = { fg = palette.rose },
        FzfLuaHeaderText = { fg = palette.red },
        FzfLuaNormal = { link = "NormalFloat" },
        FzfLuaTitle = { link = "FloatTitle" },

        NotifyBackground = { link = "NormalFloat" },
        NotifyDEBUGBody = { link = "NormalFloat" },
        NotifyDEBUGBorder = make_border(),
        NotifyDEBUGIcon = { link = "NotifyDEBUGTitle" },
        NotifyDEBUGTitle = { fg = palette.muted },
        NotifyERRORBody = { link = "NormalFloat" },
        NotifyERRORBorder = make_border("text"),
        NotifyERRORIcon = { link = "NotifyERRORTitle" },
        NotifyERRORTitle = { fg = groups.error },
        NotifyINFOBody = { link = "NormalFloat" },
        NotifyINFOBorder = make_border("text"),
        NotifyINFOIcon = { link = "NotifyINFOTitle" },
        NotifyINFOTitle = { fg = groups.info },
        NotifyTRACEBody = { link = "NormalFloat" },
        NotifyTRACEBorder = make_border("text"),
        NotifyTRACEIcon = { link = "NotifyTRACETitle" },
        NotifyTRACETitle = { fg = palette.purple },
        NotifyWARNBody = { link = "NormalFloat" },
        NotifyWARNBorder = make_border("text"),
        NotifyWARNIcon = { link = "NotifyWARNTitle" },
        NotifyWARNTitle = { fg = groups.warn },

        DapUIBreakpointsCurrentLine = { fg = palette.gold, bold = styles.bold },
        DapUIBreakpointsDisabledLine = { fg = palette.muted },
        DapUIBreakpointsInfo = { link = "DapUIThread" },
        DapUIBreakpointsLine = { link = "DapUIBreakpointsPath" },
        DapUIBreakpointsPath = { fg = palette.lavender },
        DapUIDecoration = { link = "DapUIBreakpointsPath" },
        DapUIFloatBorder = make_border(),
        DapUIFrameName = { fg = palette.text },
        DapUILineNumber = { link = "DapUIBreakpointsPath" },
        DapUIModifiedValue = { fg = palette.lavender, bold = styles.bold },
        DapUIScope = { link = "DapUIBreakpointsPath" },
        DapUISource = { fg = palette.purple },
        DapUIStoppedThread = { link = "DapUIBreakpointsPath" },
        DapUIThread = { fg = palette.gold },
        DapUIValue = { fg = palette.text },
        DapUIVariable = { fg = palette.text },
        DapUIType = { fg = palette.purple },
        DapUIWatchesEmpty = { fg = palette.red },
        DapUIWatchesError = { link = "DapUIWatchesEmpty" },
        DapUIWatchesValue = { link = "DapUIThread" },

        DashboardCenter = { fg = palette.gold },
        DashboardFooter = { fg = palette.purple },
        DashboardHeader = { fg = palette.blue },
        DashboardShortcut = { fg = palette.red },

        NavicIconsArray = { fg = palette.gold },
        NavicIconsBoolean = { fg = palette.rose },
        NavicIconsClass = { fg = palette.lavender },
        NavicIconsConstant = { fg = palette.gold },
        NavicIconsConstructor = { fg = palette.gold },
        NavicIconsEnum = { fg = palette.gold },
        NavicIconsEnumMember = { fg = palette.lavender },
        NavicIconsEvent = { fg = palette.gold },
        NavicIconsField = { fg = palette.lavender },
        NavicIconsFile = { fg = palette.muted },
        NavicIconsFunction = { fg = palette.blue },
        NavicIconsInterface = { fg = palette.lavender },
        NavicIconsKey = { fg = palette.purple },
        NavicIconsKeyword = { fg = palette.blue },
        NavicIconsMethod = { fg = palette.purple },
        NavicIconsModule = { fg = palette.rose },
        NavicIconsNamespace = { fg = palette.muted },
        NavicIconsNull = { fg = palette.red },
        NavicIconsNumber = { fg = palette.gold },
        NavicIconsObject = { fg = palette.gold },
        NavicIconsOperator = { fg = palette.subtle },
        NavicIconsPackage = { fg = palette.muted },
        NavicIconsProperty = { fg = palette.lavender },
        NavicIconsString = { fg = palette.gold },
        NavicIconsStruct = { fg = palette.lavender },
        NavicIconsTypeParameter = { fg = palette.lavender },
        NavicIconsVariable = { fg = palette.text },
        NavicSeparator = { fg = palette.subtle },
        NavicText = { fg = palette.subtle },

        NoiceCursor = { fg = palette.highlight_high, bg = palette.text },

        TroubleNormal = { fg = palette.text, bg = palette.bg },
        TroubleNormalNC = { fg = palette.text, bg = palette.bg },
        TroubleCursor = { bg = palette.bg },
        TroubleCursorLine = { bg = palette.bg },
        TroubleText = { fg = palette.subtle, bg = palette.bg },
        TroubleTextHover = { fg = palette.text, bg = palette.bg },
        TroubleCount = { fg = palette.purple, bg = palette.bg },
        TroubleCode = { fg = palette.text, bg = palette.bg },
        TroublePos = { fg = palette.subtle, bg = palette.bg },
        TroubleLocation = { fg = palette.subtle, bg = palette.bg },
        TroubleFile = { fg = palette.lavender, bg = palette.bg },
        TroubleDirectory = { fg = palette.lavender, bg = palette.bg },
        TroubleSource = { fg = palette.subtle, bg = palette.bg },
        TroubleBasename = { fg = palette.lavender, bg = palette.bg },
        TroubleDirname = { fg = palette.muted, bg = palette.bg },
        TroubleIndent = { fg = palette.muted, bg = palette.bg },
        TroubleIndentFoldClosed = { fg = palette.muted, bg = palette.bg },
        TroubleIndentFoldOpen = { fg = palette.muted, bg = palette.bg },
        TroubleSignError = { fg = palette.red, bg = palette.bg },
        TroubleSignWarning = { fg = palette.gold, bg = palette.bg },
        TroubleSignInformation = { fg = palette.lavender, bg = palette.bg },
        TroubleSignHint = { fg = palette.purple, bg = palette.bg },
        TroubleSignOther = { fg = palette.purple, bg = palette.bg },

        MiniAnimateCursor = { reverse = true, nocombine = true },
        MiniAnimateNormalFloat = { link = "NormalFloat" },

        MiniClueBorder = { link = "FloatBorder" },
        MiniClueDescGroup = { link = "DiagnosticFloatingWarn" },
        MiniClueDescSingle = { link = "NormalFloat" },
        MiniClueNextKey = { link = "DiagnosticFloatingHint" },
        MiniClueNextKeyWithPostkeys = { link = "DiagnosticFloatingError" },
        MiniClueSeparator = { link = "DiagnosticFloatingInfo" },
        MiniClueTitle = { bg = palette.bg, bold = styles.bold },

        MiniCompletionActiveParameter = { underline = true },

        MiniCursorword = { underline = true },
        MiniCursorwordCurrent = { underline = true },

        MiniDepsChangeAdded = { fg = groups.git_add },
        MiniDepsChangeRemoved = { fg = groups.git_delete },
        MiniDepsHint = { link = "DiagnosticHint" },
        MiniDepsInfo = { link = "DiagnosticInfo" },
        MiniDepsMsgBreaking = { link = "DiagnosticWarn" },
        MiniDepsPlaceholder = { link = "Comment" },
        MiniDepsTitle = { link = "Title" },
        MiniDepsTitleError = { link = "DiffDelete" },
        MiniDepsTitleSame = { link = "DiffText" },
        MiniDepsTitleUpdate = { link = "DiffAdd" },

        MiniDiffOverAdd = { fg = groups.git_add, bg = groups.git_add, blend = 20 },
        MiniDiffOverChange = { fg = groups.git_change, bg = groups.git_change, blend = 20 },
        MiniDiffOverContext = { bg = palette.bg },
        MiniDiffOverDelete = { fg = groups.git_delete, bg = groups.git_delete, blend = 20 },
        MiniDiffSignAdd = { fg = groups.git_add },
        MiniDiffSignChange = { fg = groups.git_change },
        MiniDiffSignDelete = { fg = groups.git_delete },

        MiniFilesBorder = { link = "FloatBorder" },
        MiniFilesBorderModified = { link = "DiagnosticFloatingWarn" },
        MiniFilesCursorLine = { link = "CursorLine" },
        MiniFilesDirectory = { link = "Directory" },
        MiniFilesFile = { fg = palette.text },
        MiniFilesNormal = { link = "NormalFloat" },
        MiniFilesTitle = { link = "FloatTitle" },
        MiniFilesTitleFocused = { fg = palette.rose, bg = palette.bg, bold = styles.bold },

        MiniHipatternsFixme = { fg = palette.base, bg = groups.error, bold = styles.bold },
        MiniHipatternsHack = { fg = palette.base, bg = groups.warn, bold = styles.bold },
        MiniHipatternsNote = { fg = palette.base, bg = groups.info, bold = styles.bold },
        MiniHipatternsTodo = { fg = palette.base, bg = groups.hint, bold = styles.bold },

        MiniIconsAzure = { fg = palette.lavender },
        MiniIconsBlue = { fg = palette.blue },
        MiniIconsCyan = { fg = palette.lavender },
        MiniIconsGreen = { fg = palette.green },
        MiniIconsGrey = { fg = palette.subtle },
        MiniIconsOrange = { fg = palette.rose },
        MiniIconsPurple = { fg = palette.purple },
        MiniIconsRed = { fg = palette.red },
        MiniIconsYellow = { fg = palette.gold },

        MiniIndentscopeSymbol = { fg = palette.muted },
        MiniIndentscopeSymbolOff = { fg = palette.gold },

        MiniJump = { sp = palette.gold, undercurl = true },

        MiniJump2dDim = { fg = palette.subtle },
        MiniJump2dSpot = { fg = palette.gold, bold = styles.bold, nocombine = true },
        MiniJump2dSpotAhead = { fg = palette.lavender, bg = palette.bg, nocombine = true },
        MiniJump2dSpotUnique = { fg = palette.rose, bold = styles.bold, nocombine = true },

        MiniMapNormal = { link = "NormalFloat" },
        MiniMapSymbolCount = { link = "Special" },
        MiniMapSymbolLine = { link = "Title" },
        MiniMapSymbolView = { link = "Delimiter" },

        MiniNotifyBorder = { link = "FloatBorder" },
        MiniNotifyNormal = { link = "NormalFloat" },
        MiniNotifyTitle = { link = "FloatTitle" },

        MiniOperatorsExchangeFrom = { link = "IncSearch" },

        MiniPickBorder = { link = "FloatBorder" },
        MiniPickBorderBusy = { link = "DiagnosticFloatingWarn" },
        MiniPickBorderText = { fg = palette.text, bg = palette.bg },
        MiniPickIconDirectory = { link = "Directory" },
        MiniPickIconFile = { link = "MiniPickNormal" },
        MiniPickHeader = { link = "DiagnosticFloatingHint" },
        MiniPickMatchCurrent = { link = "CursorLine" },
        MiniPickMatchMarked = { link = "Visual" },
        MiniPickMatchRanges = { fg = palette.lavender },
        MiniPickNormal = { link = "NormalFloat" },
        MiniPickPreviewLine = { link = "CursorLine" },
        MiniPickPreviewRegion = { link = "IncSearch" },
        MiniPickPrompt = { bg = palette.bg, bold = styles.bold },

        MiniStarterCurrent = { nocombine = true },
        MiniStarterFooter = { fg = palette.subtle },
        MiniStarterHeader = { link = "Title" },
        MiniStarterInactive = { link = "Comment" },
        MiniStarterItem = { link = "Normal" },
        MiniStarterItemBullet = { link = "Delimiter" },
        MiniStarterItemPrefix = { link = "WarningMsg" },
        MiniStarterSection = { fg = palette.rose },
        MiniStarterQuery = { link = "MoreMsg" },

        MiniStatuslineDevinfo = { fg = palette.subtle, bg = palette.bg },
        MiniStatuslineFileinfo = { link = "MiniStatuslineDevinfo" },
        MiniStatuslineFilename = { fg = palette.muted, bg = palette.bg },
        MiniStatuslineInactive = { link = "MiniStatuslineFilename" },
        MiniStatuslineModeCommand = { fg = palette.base, bg = palette.red, bold = styles.bold },
        MiniStatuslineModeInsert = { fg = palette.base, bg = palette.lavender, bold = styles.bold },
        MiniStatuslineModeNormal = { fg = palette.base, bg = palette.rose, bold = styles.bold },
        MiniStatuslineModeOther = { fg = palette.base, bg = palette.rose, bold = styles.bold },
        MiniStatuslineModeReplace = { fg = palette.base, bg = palette.blue, bold = styles.bold },
        MiniStatuslineModeVisual = { fg = palette.base, bg = palette.purple, bold = styles.bold },

        MiniSurround = { link = "IncSearch" },

        MiniTablineCurrent = { fg = palette.text, bg = palette.highlight_low, bold = styles.bold },
        MiniTablineFill = { link = "TabLineFill" },
        MiniTablineHidden = { fg = palette.subtle, bg = palette.bg },
        MiniTablineModifiedCurrent = { fg = palette.overlay, bg = palette.text, bold = styles.bold },
        MiniTablineModifiedHidden = { fg = groups.panel, bg = palette.subtle },
        MiniTablineModifiedVisible = { fg = groups.panel, bg = palette.text },
        MiniTablineTabpagesection = { link = "Search" },
        MiniTablineVisible = { fg = palette.text, bg = palette.bg },

        MiniTestEmphasis = { bold = styles.bold },
        MiniTestFail = { fg = palette.red, bold = styles.bold },
        MiniTestPass = { fg = palette.lavender, bold = styles.bold },

        MiniTrailspace = { bg = palette.red },

        AlphaButtons = { fg = palette.lavender },
        AlphaFooter = { fg = palette.gold },
        AlphaHeader = { fg = palette.blue },
        AlphaShortcut = { fg = palette.rose },

        CopilotSuggestion = { fg = palette.muted },

        TreesitterContext = { link = "Normal" },
        TreesitterContextLineNumber = { link = "LineNr" },
        TreesitterContextBottom = { underline = true, sp = palette.overlay },
        TreesitterContextLineNumberBottom = { underline = true, sp = palette.overlay },
        TreesitterContextSeparator = { link = "FloatBorder" },

        IlluminatedWordRead = { link = "LspReferenceRead" },
        IlluminatedWordText = { link = "LspReferenceText" },
        IlluminatedWordWrite = { link = "LspReferenceWrite" },

        RainbowDelimiterBlue = { fg = palette.blue },
        RainbowDelimiterCyan = { fg = palette.lavender },
        RainbowDelimiterGreen = { fg = palette.green },
        RainbowDelimiterOrange = { fg = palette.rose },
        RainbowDelimiterRed = { fg = palette.red },
        RainbowDelimiterViolet = { fg = palette.purple },
        RainbowDelimiterYellow = { fg = palette.gold },

        -- MeanderingProgrammer/render-markdown.nvim
        RenderMarkdownH1 = { fg = groups.h1, bold = styles.bold },
        RenderMarkdownH2 = { fg = groups.h2, bold = styles.bold },
        RenderMarkdownH3 = { fg = groups.h3, bold = styles.bold },
        RenderMarkdownH4 = { fg = groups.h4, bold = styles.bold },
        RenderMarkdownH5 = { fg = groups.h5, bold = styles.bold },
        RenderMarkdownH6 = { fg = groups.h6, bold = styles.bold },
        RenderMarkdownH1Bg = { bg = groups.h1, blend = 20 },
        RenderMarkdownH2Bg = { bg = groups.h2, blend = 20 },
        RenderMarkdownH3Bg = { bg = groups.h3, blend = 20 },
        RenderMarkdownH4Bg = { bg = groups.h4, blend = 20 },
        RenderMarkdownH5Bg = { bg = groups.h5, blend = 20 },
        RenderMarkdownH6Bg = { bg = groups.h6, blend = 20 },
        RenderMarkdownCode = { bg = palette.surface },
        RenderMarkdownCodeInfo = { fg = palette.subtle, bg = palette.bg },
        RenderMarkdownCodeBorder = { fg = groups.border, bg = palette.bg },
        RenderMarkdownCodeLanguage = { fg = groups.link, bold = styles.bold },
        RenderMarkdownCodeFallback = { fg = palette.muted },
        RenderMarkdownCodeInline = { fg = palette.lavender, bg = palette.surface },
        RenderMarkdownQuote1 = { fg = palette.subtle },
        RenderMarkdownQuote2 = { fg = groups.h2 },
        RenderMarkdownQuote3 = { fg = groups.h3 },
        RenderMarkdownQuote4 = { fg = groups.h4 },
        RenderMarkdownQuote5 = { fg = groups.h5 },
        RenderMarkdownQuote6 = { fg = groups.h6 },
        RenderMarkdownQuote = { link = "RenderMarkdownQuote1" },
        RenderMarkdownLink = { fg = groups.link },
        RenderMarkdownWikiLink = { fg = groups.link },
        RenderMarkdownWikiLinkText = { fg = palette.text },
        RenderMarkdownWikiLinkUnderline = { sp = groups.link },
        RenderMarkdownUnchecked = { fg = palette.subtle },
        RenderMarkdownChecked = { fg = palette.lavender },
        RenderMarkdownTodo = { fg = groups.todo },
        RenderMarkdownTableHead = { fg = palette.subtle, bold = styles.bold },
        RenderMarkdownTableRow = { fg = palette.subtle },
        RenderMarkdownTableFill = { link = "Conceal" },
        RenderMarkdownInfo = { fg = groups.info, bg = groups.info, blend = 10 },
        RenderMarkdownSuccess = { fg = groups.ok, bg = groups.ok, blend = 10 },
        RenderMarkdownHint = { fg = groups.hint, bg = groups.hint, blend = 10 },
        RenderMarkdownWarn = { fg = groups.warn, bg = groups.warn, blend = 10 },
        RenderMarkdownError = { fg = groups.error, bg = groups.error, blend = 10 },
        RenderMarkdownBullet = { fg = palette.rose },
        RenderMarkdownDash = { fg = palette.muted },
        RenderMarkdownSign = { fg = palette.subtle },
        RenderMarkdownMath = { fg = palette.purple },
        RenderMarkdownIndent = { fg = palette.muted, nocombine = true },
        RenderMarkdownHtmlComment = { fg = palette.highlight_high, italic = styles.italic },
        RenderMarkdownInlineHighlight = { fg = palette.text, bg = palette.highlight_low },

        GrugFarHelpHeader = { fg = palette.blue },
        GrugFarHelpHeaderKey = { fg = palette.gold },
        GrugFarHelpWinActionKey = { fg = palette.gold },
        GrugFarHelpWinActionPrefix = { fg = palette.lavender },
        GrugFarHelpWinActionText = { fg = palette.blue },
        GrugFarHelpWinHeader = { link = "FloatTitle" },
        GrugFarInputLabel = { fg = palette.lavender },
        GrugFarInputPlaceholder = { link = "Comment" },
        GrugFarResultsActionMessage = { fg = palette.lavender },
        GrugFarResultsChangeIndicator = { fg = groups.git_change },
        GrugFarResultsRemoveIndicator = { fg = groups.git_delete },
        GrugFarResultsAddIndicator = { fg = groups.git_add },
        GrugFarResultsHeader = { fg = palette.blue },
        GrugFarResultsLineNo = { fg = palette.purple },
        GrugFarResultsLineColumn = { link = "GrugFarResultsLineNo" },
        GrugFarResultsMatch = { link = "CurSearch" },
        GrugFarResultsPath = { fg = palette.lavender },
        GrugFarResultsStats = { fg = palette.purple },

        AvanteTitle = { fg = palette.highlight_high, bg = palette.rose },
        AvanteReversedTitle = { fg = palette.rose },
        AvanteSubtitle = { fg = palette.highlight_med, bg = palette.lavender },
        AvanteReversedSubtitle = { fg = palette.lavender },
        AvanteThirdTitle = { fg = palette.highlight_med, bg = palette.purple },
        AvanteReversedThirdTitle = { fg = palette.purple },
        AvantePromptInput = { fg = palette.text, bg = palette.bg },
        AvantePromptInputBorder = { fg = groups.border },

        BlinkCmpMenu = { fg = palette.text, bg = palette.bg },
        BlinkCmpMenuBorder = { fg = palette.text, bg = palette.bg },
        BlinkCmpMenuSelection = { fg = palette.text, bg = palette.highlight_low },
        BlinkCmpScrollBarThumb = { bg = palette.muted },
        BlinkCmpScrollBarGutter = { bg = palette.bg },
        BlinkCmpLabel = { fg = palette.text, bg = palette.bg },
        BlinkCmpLabelDeprecated = { fg = palette.muted, bg = palette.bg },
        BlinkCmpLabelMatch = { fg = palette.rose, bg = palette.bg },
        BlinkCmpLabelDetail = { fg = palette.subtle, bg = palette.bg },
        BlinkCmpLabelDescription = { fg = palette.subtle, bg = palette.bg },
        BlinkCmpKind = { fg = palette.purple, bg = palette.bg },
        BlinkCmpSource = { fg = palette.muted, bg = palette.bg },
        BlinkCmpGhostText = { fg = palette.muted, bg = "NONE" },
        BlinkCmpDoc = { fg = palette.text, bg = palette.bg },
        BlinkCmpDocBorder = { fg = palette.text, bg = palette.bg },
        BlinkCmpDocSeparator = { fg = palette.muted, bg = palette.bg },
        BlinkCmpDocCursorLine = { bg = palette.highlight_low },
        BlinkCmpSignatureHelp = { fg = palette.text, bg = palette.bg },
        BlinkCmpSignatureHelpBorder = { fg = palette.text, bg = palette.bg },
        BlinkCmpSignatureHelpActiveParameter = { fg = palette.rose, bg = palette.bg },

        BlinkCmpDefault = { fg = palette.highlight_med },
        BlinkCmpKindText = { fg = palette.blue },
        BlinkCmpKindMethod = { fg = palette.lavender },
        BlinkCmpKindFunction = { fg = palette.lavender },
        BlinkCmpKindConstructor = { fg = palette.lavender },
        BlinkCmpKindField = { fg = palette.blue },
        BlinkCmpKindVariable = { fg = palette.rose },
        BlinkCmpKindClass = { fg = palette.gold },
        BlinkCmpKindInterface = { fg = palette.gold },
        BlinkCmpKindModule = { fg = palette.lavender },
        BlinkCmpKindProperty = { fg = palette.lavender },
        BlinkCmpKindUnit = { fg = palette.blue },
        BlinkCmpKindValue = { fg = palette.red },
        BlinkCmpKindKeyword = { fg = palette.purple },
        BlinkCmpKindSnippet = { fg = palette.rose },
        BlinkCmpKindColor = { fg = palette.red },
        BlinkCmpKindFile = { fg = palette.lavender },
        BlinkCmpKindReference = { fg = palette.red },
        BlinkCmpKindFolder = { fg = palette.lavender },
        BlinkCmpKindEnum = { fg = palette.lavender },
        BlinkCmpKindEnumMember = { fg = palette.lavender },
        BlinkCmpKindConstant = { fg = palette.gold },
        BlinkCmpKindStruct = { fg = palette.lavender },
        BlinkCmpKindEvent = { fg = palette.lavender },
        BlinkCmpKindOperator = { fg = palette.lavender },
        BlinkCmpKindTypeParameter = { fg = palette.purple },
        BlinkCmpKindCodeium = { fg = palette.lavender },
        BlinkCmpKindCopilot = { fg = palette.lavender },
        BlinkCmpKindSupermaven = { fg = palette.lavender },
        BlinkCmpKindTabNine = { fg = palette.lavender },

        SnacksIndent = { fg = palette.overlay },
        SnacksIndentChunk = { fg = palette.overlay },
        SnacksIndentBlank = { fg = palette.overlay },
        SnacksIndentScope = { fg = palette.lavender },

        SnacksPicker = { fg = palette.text, bg = palette.bg },
        SnacksPickerBorder = { fg = palette.text, bg = palette.bg },
        SnacksPickerList = { fg = palette.text, bg = palette.bg },
        SnacksPickerPreview = { fg = palette.text, bg = palette.bg },
        SnacksPickerInput = { fg = palette.text, bg = palette.bg },
        SnacksPickerMatch = { fg = palette.rose, bold = styles.bold },

        Sneak = { fg = palette.base, bg = palette.red },
        SneakCurrent = { link = "StatusLineTerm" },
        SneakScope = { link = "IncSearch" },

        DiffviewPrimary = { fg = palette.blue },
        DiffviewSecondary = { fg = palette.lavender },
        DiffviewNormal = { fg = palette.text, bg = palette.bg },
        DiffviewWinSeparator = { fg = palette.text, bg = palette.bg },

        DiffviewFilePanelTitle = { fg = palette.lavender, bold = styles.bold },
        DiffviewFilePanelCounter = { fg = palette.rose },
        DiffviewFilePanelRootPath = { fg = palette.lavender, bold = styles.bold },
        DiffviewFilePanelFileName = { fg = palette.text },
        DiffviewFilePanelSelected = { fg = palette.gold },
        DiffviewFilePanelPath = { link = "Comment" },

        DiffviewFilePanelInsertions = { fg = groups.git_add },
        DiffviewFilePanelDeletions = { fg = groups.git_delete },
        DiffviewFilePanelConflicts = { fg = groups.git_merge },
        DiffviewFolderName = { fg = palette.lavender, bold = styles.bold },
        DiffviewFolderSign = { fg = palette.subtle },
        DiffviewHash = { fg = palette.rose },
        DiffviewReference = { fg = palette.lavender, bold = styles.bold },
        DiffviewReflogSelector = { fg = palette.rose },
        DiffviewStatusAdded = { fg = groups.git_add },
        DiffviewStatusUntracked = { fg = groups.untracked },
        DiffviewStatusModified = { fg = groups.git_change },
        DiffviewStatusRenamed = { fg = groups.git_rename },
        DiffviewStatusCopied = { fg = groups.untracked },
        DiffviewStatusTypeChange = { fg = groups.git_change },
        DiffviewStatusUnmerged = { fg = groups.git_change },
        DiffviewStatusUnknown = { fg = groups.git_delete },
        DiffviewStatusDeleted = { fg = groups.git_delete },
        DiffviewStatusBroken = { fg = groups.git_delete },
        DiffviewStatusIgnored = { fg = groups.git_ignore },
    }
    local transparency_highlights = {
        DiagnosticVirtualTextError = { fg = groups.error },
        DiagnosticVirtualTextHint = { fg = groups.hint },
        DiagnosticVirtualTextInfo = { fg = groups.info },
        DiagnosticVirtualTextOk = { fg = groups.ok },
        DiagnosticVirtualTextWarn = { fg = groups.warn },

        FloatBorder = { fg = palette.text, bg = "NONE" },
        FloatTitle = { fg = palette.lavender, bg = "NONE", bold = styles.bold },
        Folded = { fg = palette.text, bg = "NONE" },
        NormalFloat = { bg = "NONE" },
        Normal = { fg = palette.text, bg = "NONE" },
        NormalNC = { fg = palette.text, bg = config.options.dim_inactive_windows and palette.nc or "NONE" },
        Pmenu = { fg = palette.subtle, bg = "NONE" },
        PmenuKind = { fg = palette.lavender, bg = "NONE" },
        SignColumn = { fg = palette.text, bg = "NONE" },
        StatusLine = { fg = palette.subtle, bg = "NONE" },
        StatusLineNC = { fg = palette.muted, bg = "NONE" },
        TabLine = { bg = "NONE", fg = palette.subtle },
        TabLineFill = { bg = "NONE" },
        TabLineSel = { fg = palette.text, bg = "NONE", bold = styles.bold },

        ["@markup.raw.markdown_inline"] = { fg = palette.gold },

        TelescopeNormal = { fg = palette.subtle, bg = "NONE" },
        TelescopePromptNormal = { fg = palette.text, bg = "NONE" },
        TelescopeSelection = { fg = palette.text, bg = "NONE", bold = styles.bold },
        TelescopeSelectionCaret = { fg = palette.rose },

        TroubleNormal = { bg = "NONE" },

        WhichKeyFloat = { bg = "NONE" },
        WhichKeyNormal = { bg = "NONE" },

        IblIndent = { fg = palette.overlay, bg = "NONE" },
        IblScope = { fg = palette.lavender, bg = "NONE" },
        IblWhitespace = { fg = palette.overlay, bg = "NONE" },

        TreesitterContext = { bg = "NONE" },
        TreesitterContextLineNumber = { fg = palette.rose, bg = "NONE" },

        MiniFilesTitleFocused = { fg = palette.rose, bg = "NONE", bold = styles.bold },

        MiniPickPrompt = { bg = "NONE", bold = styles.bold },
        MiniPickBorderText = { fg = palette.text, bg = "NONE" },
    }

    if config.options.enable.legacy_highlights then
        for group, highlight in pairs(legacy_highlights) do
            highlights[group] = highlight
        end
    end
    for group, highlight in pairs(default_highlights) do
        highlights[group] = highlight
    end
    if styles.transparency then
        for group, highlight in pairs(transparency_highlights) do
            highlights[group] = highlight
        end
    end

    if config.options.highlight_groups ~= nil and next(config.options.highlight_groups) ~= nil then
        for group, highlight in pairs(config.options.highlight_groups) do
            local existing = highlights[group] or {}
            while existing.link ~= nil do
                existing = highlights[existing.link] or {}
            end
            local parsed = vim.tbl_extend("force", {}, highlight)

            if highlight.fg ~= nil then
                parsed.fg = utilities.parse_color(highlight.fg) or highlight.fg
            end
            if highlight.bg ~= nil then
                parsed.bg = utilities.parse_color(highlight.bg) or highlight.bg
            end
            if highlight.sp ~= nil then
                parsed.sp = utilities.parse_color(highlight.sp) or highlight.sp
            end

            if (highlight.inherit == nil or highlight.inherit) and existing ~= nil then
                parsed.inherit = nil
                highlights[group] = vim.tbl_extend("force", existing, parsed)
            else
                parsed.inherit = nil
                highlights[group] = parsed
            end
        end
    end

    for group, highlight in pairs(highlights) do
        if config.options.before_highlight ~= nil then
            config.options.before_highlight(group, highlight, palette)
        end

        if highlight.blend ~= nil and (highlight.blend >= 0 and highlight.blend <= 100) and highlight.bg ~= nil then
            highlight.bg = utilities.blend(highlight.bg, highlight.blend_on or palette.bg, highlight.blend / 100)
        end

        highlight.blend = nil
        highlight.blend_on = nil

        if highlight._nvim_blend ~= nil then
            highlight.blend = highlight._nvim_blend
        end

        vim.api.nvim_set_hl(0, group, highlight)
    end

    if config.options.enable.terminal then
        vim.g.terminal_color_0 = palette.overlay
        vim.g.terminal_color_8 = palette.subtle
        vim.g.terminal_color_1 = palette.red
        vim.g.terminal_color_9 = palette.red
        vim.g.terminal_color_2 = palette.blue
        vim.g.terminal_color_10 = palette.blue
        vim.g.terminal_color_3 = palette.gold
        vim.g.terminal_color_11 = palette.gold
        vim.g.terminal_color_4 = palette.lavender
        vim.g.terminal_color_12 = palette.lavender
        vim.g.terminal_color_5 = palette.purple
        vim.g.terminal_color_13 = palette.purple
        vim.g.terminal_color_6 = palette.rose
        vim.g.terminal_color_14 = palette.rose
        vim.g.terminal_color_7 = palette.text
        vim.g.terminal_color_15 = palette.text

        vim.cmd([[
		augroup misirlou
			autocmd!
			autocmd TermOpen * if &buftype=='terminal'
				\|setlocal winhighlight=StatusLine:StatusLineTerm,StatusLineNC:StatusLineTermNC
				\|else|setlocal winhighlight=|endif
			autocmd ColorSchemePre * autocmd! misirlou
		augroup END
		]])
    end
end

function M.colorscheme()
    vim.opt.termguicolors = true
    if vim.g.colors_name then
        vim.cmd("hi clear")
        vim.cmd("syntax reset")
    end
    vim.g.colors_name = "misirlou-gitg"
    vim.o.background = "dark"

    set_highlights()
end

function M.setup(options)
    config.extend_options(options or {})
end

M.colorscheme()

return M
