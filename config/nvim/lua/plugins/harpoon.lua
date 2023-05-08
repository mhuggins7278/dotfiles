return {
    'theprimeagen/harpoon',
    event = 'BufRead',
    config = function()
        local mark = require("harpoon.mark")
        local ui = require("harpoon.ui")

        vim.keymap.set("n", "<leader>a", mark.add_file, {desc = "Harpoon Add file"})
        vim.keymap.set("n", "<leader>h", ui.toggle_quick_menu, {desc = "Harpoon Toggle menu"})

        vim.keymap.set("n", "<M-j>", function() ui.nav_file(1) end)
        vim.keymap.set("n", "<M-k>", function() ui.nav_file(2) end)
        vim.keymap.set("n", "<M-l>", function() ui.nav_file(3) end)
        vim.keymap.set("n", "<M-;>", function() ui.nav_file(4) end)
    end
    }

