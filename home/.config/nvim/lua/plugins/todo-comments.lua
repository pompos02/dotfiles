return {
    "nvim-mini/mini.hipatterns",
    opts = {
        highlighters = {
            fixme     = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
            hack      = { pattern = '%f[%w]()HACK()%f[%W]', group = 'MiniHipatternsFixme' },
            todo      = { pattern = '%f[%w]()TODO()%f[%W]', group = 'MiniHipatternsFixme' },
            note      = { pattern = '%f[%w]()NOTE()%f[%W]', group = 'MiniHipatternsFixme' },
        },
    },
}
