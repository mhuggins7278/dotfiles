return {
  'ThePrimeagen/refactoring.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'lewis6991/async.nvim',
  },
  keys = {
    { '<leader>re', mode = 'x', desc = '[R]efactor [E]xtract function' },
    { '<leader>rf', mode = 'x', desc = '[R]efactor extract to [F]ile' },
    { '<leader>rv', mode = 'x', desc = '[R]efactor extract [V]ariable' },
    { '<leader>ri', mode = { 'n', 'x' }, desc = '[R]efactor [I]nline variable' },
    { '<leader>rI', desc = '[R]efactor [I]nline function' },
    { '<leader>rb', desc = '[R]efactor extract [B]lock' },
    { '<leader>rbf', desc = '[R]efactor extract [B]lock to [F]ile' },
  },
  config = function()
    require('refactoring').setup {}

    -- Extract function/variable
    vim.keymap.set('x', '<leader>re', ':Refactor extract ', { desc = '[R]efactor [E]xtract function' })
    vim.keymap.set('x', '<leader>rf', ':Refactor extract_to_file ', { desc = '[R]efactor extract to [F]ile' })
    vim.keymap.set('x', '<leader>rv', ':Refactor extract_var ', { desc = '[R]efactor extract [V]ariable' })

    -- Inline function/variable
    vim.keymap.set({ 'n', 'x' }, '<leader>ri', ':Refactor inline_var', { desc = '[R]efactor [I]nline variable' })
    vim.keymap.set('n', '<leader>rI', ':Refactor inline_func', { desc = '[R]efactor [I]nline function' })

    -- Extract block
    vim.keymap.set('n', '<leader>rb', ':Refactor extract_block', { desc = '[R]efactor extract [B]lock' })
    vim.keymap.set('n', '<leader>rbf', ':Refactor extract_block_to_file', { desc = '[R]efactor extract [B]lock to [F]ile' })

    -- Refactor selection menu
  end,
}
