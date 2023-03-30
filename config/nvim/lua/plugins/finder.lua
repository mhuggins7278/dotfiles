return {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.0',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
        local actions = require "telescope.actions"
        local action_state = require "telescope.actions.state"
        actions.select_default:replace(function()
            actions.select_default()
            actions.center()
        end)
        require('telescope').setup {
            extensions = {
                ["ui-select"] = {
                    require("telescope.themes").get_dropdown {
                    }
                },
                ["file_browser"] = {
                  hijack_netrw = true,
                },
            },
        }
        require('telescope').load_extension('projects')
        require("telescope").load_extension("fzf")
        require("telescope").load_extension("ui-select")
        require("telescope").load_extension("file_browser")
        require("telescope").load_extension("live_grep_args")
        vim.keymap.set('n', '<leader>sf', "<cmd>Telescope find_files<cr>", { desc = 'Find All Files' })
        vim.keymap.set('n', '<leader>sF', "<cmd>Telescope file_browser<cr>", { desc = 'File Browser' })
        vim.keymap.set('n', '<leader>sg', "<cmd>Telescope git_files<cr>", { desc = 'Find Git Files' })
        vim.keymap.set('n', '<leader>sw', "<cmd>Telescope grep_string<cr>", { desc = 'Find Current Word' })
        vim.keymap.set('n', '<leader>st', ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>", { desc = 'Find Text' })
        vim.keymap.set('n', '<leader>sb', "<cmd>Telescope buffers<cr>", { desc = 'Find Buffers' })
        vim.keymap.set('n', '<leader>sr', "<cmd>Telescope oldfiles<cr>", { desc = 'Find Recent Files' })
        vim.keymap.set('n', '<leader>sh', "<cmd>Telescope help_tags<cr>", { desc = 'Help' })
        vim.keymap.set('n', '<leader>sp', "<cmd>Telescope projects<cr>", { desc = 'Find Project' })
        vim.keymap.set('n', '<leader>sR', "<cmd>Telescope resume<cr>", { desc = 'Reopen' })
    end
}
