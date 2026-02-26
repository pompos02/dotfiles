return {

    -- dir = "/home/karavellas/projects/opensource/live-markdown.nvim",
    "pompos02/live-markdown.nvim",
    --build = "./scripts/build-nvim-module.sh release",
    config = function()
        require("live_markdown").setup({
            port = 6419,
            debounce_ms_content = 100,
            throttle_ms_cursor = 24,
            bind_address = "127.0.0.1",
            auto_scroll = true,
            scroll_comfort_top = 0.25,
            scroll_comfort_bottom = 0.65,
        })
    end,
}
