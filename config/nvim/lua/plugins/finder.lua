return {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.0',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
        require('telescope').load_extension('projects')
        require("telescope").load_extension("fzf")
        require("telescope").load_extension("ui-select")
        require("project_nvim").setup {
            patterns = { ".git" }
        }
        require('telescope').setup {
            extensions = {
                ["ui-select"] = {
                    require("telescope.themes").get_cursor {
                    }
                }
            }
        }
        vim.keymap.set('n', '<leader>sf', "<cmd>Telescope find_files<cr>", { desc = 'Find All Files' })
        vim.keymap.set('n', '<leader>sg', "<cmd>Telescope git_files<cr>", { desc = 'Find Git Files' })
        vim.keymap.set('n', '<leader>sw', "<cmd>Telescope grep_string<cr>", { desc = 'Find Current Word' })
        vim.keymap.set('n', '<leader>st', "<cmd>Telescope live_grep<cr>", { desc = 'Find Text' })
        vim.keymap.set('n', '<leader>sb', "<cmd>Telescope buffers<cr>", { desc = 'Find Buffers' })
        vim.keymap.set('n', '<leader>sr', "<cmd>Telescope oldfiles<cr>", { desc = 'Find Recent Files' })
        vim.keymap.set('n', '<leader>sh', "<cmd>Telescope help_tags<cr>", { desc = 'Help' })
        vim.keymap.set('n', '<leader>sp', "<cmd>Telescope projects<cr>", { desc = 'Find Project' })
        vim.keymap.set('n', '<leader>sR', "<cmd>Telescope resume<cr>", { desc = 'Reopen' })
    end
}
