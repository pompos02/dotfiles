-- File to disable unwanted LazyVim plugins
-- Place this file at: ~/.config/nvim/lua/plugins/disable.lua

return {
    {
        "folke/snacks.nvim",
        opts = {
            explorer = {
                enabled = false, -- This disables the explorer component
            },
            -- You can keep other snacks options here if you have them
            -- For example:
            -- dashboard = { enabled = true },
            -- picker = { ... },
        },
    },
    -- Disable noice.nvim (UI improvements)
    { "folke/noice.nvim", enabled = false },
    { "akinsho/bufferline.nvim", enabled = false },
    -- Disable nui.nvim (UI components library)
    -- { "MunifTanjim/nui.nvim", enabled = false },
    { "nvim-neo-tree/neo-tree.nvim", enabled = false },
    -- Disable persistence.nvim (session management)
    { "folke/persistence.nvim", enabled = false },
}
