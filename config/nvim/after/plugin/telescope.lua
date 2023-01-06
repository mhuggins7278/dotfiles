require('telescope').load_extension('projects')
require("telescope").load_extension("fzf")
require("telescope").load_extension("ui-select")
require("project_nvim").setup {
     patterns = { ".git"}
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
}

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = 'Find All Files' })
vim.keymap.set('n', '<leader>sg', builtin.git_files, { desc = 'Find Git Files' })
vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = 'Find Current Word' })
vim.keymap.set('n', '<leader>st', builtin.live_grep, { desc = 'Find Text' })
vim.keymap.set('n', '<leader>sp', "<cmd>Telescope projects<cr>", { desc = 'Find Project' })

require('telescope').setup {
    extensions = {
        ["ui-select"] = {
            require("telescope.themes").get_cursor {
                -- even more opts
            }
        }
    }
}
