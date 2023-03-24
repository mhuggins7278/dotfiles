return {
    {
        'lewis6991/gitsigns.nvim',
        event = 'BufRead',
        config = function()
            require('gitsigns').setup({
              numhl = true,
              linehl = true
            })
        end
    },
    {
        { vim.keymap.set({ 'n', 'v' }, '<leader>gs', ':Gitsigns stage_hunk<CR>', { desc = 'Stage hunk' }) },
        { vim.keymap.set({ 'n', 'v' }, '<leader>gr', ':Gitsigns reset_hunk<CR>', { desc = 'Reset hunk' }) },
        { vim.keymap.set('n', '<leader>gS', ':Gitsigns stage_buffer<CR>', { desc = 'Stage buffer' }) },
        { vim.keymap.set('n', '<leader>gu', ':Gitsigns undo_stage_hunk<CR>', { desc = 'Undo stage hunk' }) },
        { vim.keymap.set('n', '<leader>gR', ':Gitsigns reset_buffer<CR>', { desc = 'Reset buffer' }) },
        { vim.keymap.set('n', '<leader>gP', ':Gitsigns preview_hunk<CR>', { desc = 'Preview hunk' }) },
        { vim.keymap.set('n', '<leader>gB', ':Gitsigns blame_line<CR>', { desc = 'Blame line' }) },
        { vim.keymap.set('n', '<leader>gb', ':Gitsigns toggle_current_line_blame<CR>', { desc = 'Toggle blame' }) },
        { vim.keymap.set('n', '<leader>gd', ':Gitsigns diffthis<CR>', { desc = 'Diff this' }) },
        { vim.keymap.set('n', '<leader>gD', ':Gitsigns diffthis<CR>', { desc = 'Diff this against HEAD' }) },
        { vim.keymap.set('n', '<leader>gx', ':Gitsigns toggle_deleted<CR>', { desc = 'Toggle deleted' }) },
        { vim.keymap.set('n', '<leader>gp', ':Gitsigns prev_hunk<CR>', { desc = 'Prev Hunk' }) },
        { vim.keymap.set('n', '<leader>gn', ':Gitsigns next_hunk<CR>', { desc = 'Next Hunk' }) },

    }
}
