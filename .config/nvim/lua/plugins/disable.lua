-- File to disable unwanted LazyVim plugins
-- Place this file at: ~/.config/nvim/lua/plugins/disable.lua

return {

    { "folke/flash.nvim", enabled = false },

    -- Disable grug-far.nvim (search and replace)
    -- { "MagicDuck/grug-far.nvim", enabled = false },

    -- Disable noice.nvim (UI improvements)
    { "folke/noice.nvim", enabled = false },

    -- Disable nui.nvim (UI components library)
    { "MunifTanjim/nui.nvim", enabled = false },

    -- Disable persistence.nvim (session management)
    { "folke/persistence.nvim", enabled = false },

    -- Disable todo-comments.nvim (TODO highlighting)
    { "folke/todo-comments.nvim", enabled = false },

    -- Disable trouble.nvim (diagnostics list)
    { "folke/trouble.nvim", enabled = false },

    -- Disable which-key.nvim (keybinding help)
    { "folke/which-key.nvim", enabled = false },
}
