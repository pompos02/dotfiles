return {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    opts = {
        heading = {
            atx = false,
        },
        code = {
            position = 'left',
            width = 'block',
            right_pad = 10,
            sign = false,
        },
        checkbox = {
            checked = { scope_highlight = '@markup.strikethrough' }
        },
        sign = { enabled = false },
    },
}
