return {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    opts = {
        heading = { enabled = false },
        code = {
            position = 'left',
            width = 'block',
            right_pad = 10,
            sign = false,
        },
        quote = { enabled = false },
        checkbox = {
            checked = { scope_highlight = '@markup.strikethrough' }
        },
        sign = { enabled = false },
        link = {
            image = '',
            email = '',
            hyperlink = '',
            highlight = 'RenderMarkdownLink',
            highlight_title = 'RenderMarkdownLinkTitle',
            wiki = {
                enabled = true,
                icon = '',
                body = function()
                    return nil
                end,
                highlight = 'RenderMarkdownWikiLink',
                scope_highlight = nil,
            },
            custom = {
                web = { pattern = '^http', icon = '' },
                apple = { pattern = 'apple%.com', icon = '' },
                discord = { pattern = 'discord%.com', icon = '' },
                github = { pattern = 'github%.com', icon = '' },
                gitlab = { pattern = 'gitlab%.com', icon = '' },
                google = { pattern = 'google%.com', icon = '' },
                hackernews = { pattern = 'ycombinator%.com', icon = '' },
                linkedin = { pattern = 'linkedin%.com', icon = '' },
                microsoft = { pattern = 'microsoft%.com', icon = '' },
                neovim = { pattern = 'neovim%.io', icon = '' },
                reddit = { pattern = 'reddit%.com', icon = '' },
                slack = { pattern = 'slack%.com', icon = '' },
                stackoverflow = { pattern = 'stackoverflow%.com', icon = '' },
                steam = { pattern = 'steampowered%.com', icon = '' },
                twitter = { pattern = 'twitter%.com', icon = '' },
                wikipedia = { pattern = 'wikipedia%.org', icon = '' },
                x = { pattern = 'x%.com', icon = '' },
                youtube = { pattern = 'youtube[^.]*%.com', icon = '' },
                youtube_short = { pattern = 'youtu%.be', icon = '' },
            },
        },

    },
}
