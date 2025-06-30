-- Disable dashboard completely
-- Place this file at: ~/.config/nvim/lua/plugins/dashboard.lua

return {
    {
        "snacks.nvim",
        opts = {
            dashboard = { enabled = false },
        },
    },
}
