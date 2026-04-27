-- Packer
return {
    -- "esmuellert/codediff.nvim",
    dir = "/home/karavellas/projects/opensource/codediff.nvim",
    cmd = "CodeDiff",
    opts = {
        highlights = {
            char_brightness = nil,
        },
        diff = {
            ignore_trim_whitespace = false, -- Ignore leading/trailing whitespace changes (like diffopt+=iwhite)
        },
    },
}
