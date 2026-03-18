return {
    "chrisgrieser/nvim-origami",
    event = "VeryLazy",
    opts = {
        autoFold = {
            enabled = false,
        },
    },
    foldKeymaps = {
        setup = true, -- modifies `h`, `l`, `^`, and `$`
        closeOnlyOnFirstColumn = false, -- `h` and `^` only fold in the 1st column
        scrollLeftOnCaret = false, -- `^` should scroll left (basically mapped to `0^`)
    },
    -- recommended: disable vim's auto-folding
    init = function()
        vim.opt.foldlevel = 99
        vim.opt.foldlevelstart = 99
    end,
}
