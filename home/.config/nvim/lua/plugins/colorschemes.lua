return {
    "vague2k/vague.nvim",
    "pompos02/modus-themes.nvim",
    "folke/tokyonight.nvim",
    {
        dir = "/home/karavellas/devel/dolores.nvim",
        opts = {
            styles = {
                bold = false,
                italic = false,
                transparent = true,
            }
        },
    },
    {
        "neanias/everforest-nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("everforest").setup({ background = "hard" })
        end,
    },
    "datsfilipe/vesper.nvim",
    "sainnhe/sonokai",
    "navarasu/onedark.nvim",
    {
        "rose-pine/neovim",
        name = "rose-pine",
        opts = {
            styles = {
                transparency = true,
            },
        },
    },
    "kepano/flexoki-neovim",
    "f4z3r/gruvbox-material.nvim",
    "whizikxd/naysayer-colors.nvim",
    "mountain-theme/vim",
    "oskarnurm/koda.nvim",
    "catppuccin/nvim",
    "rebelot/kanagawa.nvim",
    "scottmckendry/cyberdream.nvim",
    "metalelf0/jellybeans-nvim",
    "bluz71/vim-moonfly-colors",
    "slugbyte/lackluster.nvim",
    "ThunderBoltCODMYT/gruber-darker.vim",
    "EdenEast/nightfox.nvim",
    "RostislavArts/naysayer.nvim",
    "AlexvZyl/nordic.nvim",
    "ramojus/mellifluous.nvim",
    "deparr/tairiki.nvim",
    "Mofiqul/dracula.nvim",
    "mhartington/oceanic-next",
    {
        "zenbones-theme/zenbones.nvim",
        dependencies = "rktjmp/lush.nvim",
        lazy = false,
        priority = 1000,
        -- you can set set configuration options here
        -- config = function()
        --     vim.g.zenbones_darken_comments = 45
        --     vim.cmd.colorscheme('zenbones')
        -- end
    },
    "yorik1984/newpaper.nvim",
    "kvrohit/rasmus.nvim",
    "nickkadutskyi/jb.nvim",
    "RRethy/base16-nvim",
    "wtfox/luna.nvim",
    { "marko-cerovac/material.nvim", opts = { plugins = { "blink", "neogit", }, disable = { colored_cursor = true, } } },
    { "ellisonleao/gruvbox.nvim",    opts = {} },
{'alljokecake/naysayer-theme.nvim', as = 'naysayer'}

}
