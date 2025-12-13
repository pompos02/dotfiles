local M = {}

function M.setup()
    -- Use the built-in syntax engine for fenced code blocks (no treesitter required)
    vim.cmd.syntax("enable")
    vim.g.markdown_fenced_languages = {
        "bash=sh",
        "sh",
        "zsh",
        "lua",
        "python",
        "go",
        "gomod=go",
        "javascript",
        "typescript",
        "tsx=typescriptreact",
        "json",
        "yaml",
        "toml",
        "html",
        "css",
        "c",
        "cpp",
        "rust",
        "sql",
    }
end

return M
