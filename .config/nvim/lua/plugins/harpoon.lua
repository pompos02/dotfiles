return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    config = function()
        local harpoon = require("harpoon")
        harpoon:setup()

        -- Map <C-h><C-m> to add the current file to the harpoon list
        vim.keymap.set("n", "<leader>hm", function()
            harpoon:list():add()
        end, { desc = "Harpoon: Add File" })

        -- Map <C-h><C-l> to toggle the quick menu/UI
        vim.keymap.set("n", "<leader>hl", function()
            harpoon.ui:toggle_quick_menu(harpoon:list())
        end, { desc = "Harpoon: Toggle Menu" })

        -- Set <space>1..<space>5 as shortcuts to jump to the harpooned files
        for _, idx in ipairs({ 1, 2, 3, 4, 5 }) do
            vim.keymap.set("n", string.format("<space>%d", idx), function()
                harpoon:list():select(idx)
            end, { desc = string.format("Harpoon: Go to File %d", idx) })
        end
    end,
}
