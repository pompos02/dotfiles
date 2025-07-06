-- File to disable unwanted LazyVim plugins
-- Place this file at: ~/.config/nvim/lua/plugins/disable.lua

return {

  -- Disable noice.nvim (UI improvements)
  { "folke/noice.nvim", enabled = false },

  -- Disable nui.nvim (UI components library)
  -- { "MunifTanjim/nui.nvim", enabled = false },

  -- Disable persistence.nvim (session management)
  { "folke/persistence.nvim", enabled = false },
}
