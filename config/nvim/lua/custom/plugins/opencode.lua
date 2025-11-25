return {
  'NickvanDyke/opencode.nvim',
  dependencies = {
    -- Recommended for `ask()` and `select()`.
    -- Required for `snacks` provider.
    ---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
    { 'folke/snacks.nvim', opts = { input = {}, picker = {}, terminal = {} } },
  },
  config = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      provider = {
        enabled = 'tmux', -- Default if inside a `tmux` session.
        tmux = {
          options = '-h', -- Options to pass to `tmux split-window`.
        },
      },
      -- Your configuration, if any — see `lua/opencode/config.lua`, or "goto definition".
    }

    -- Required for `opts.events.reload`.
    vim.o.autoread = true

    -- Recommended/example keymaps.
    vim.keymap.set({ 'n', 'x' }, '<leader>a', function()
      require('opencode').ask('@this: ', { submit = true })
    end, { desc = 'Ask opencode' })
    vim.keymap.set({ 'n', 'x' }, '<C-x>', function()
      require('opencode').select()
    end, { desc = 'Execute opencode action…' })
    vim.keymap.set({ 'n', 'x' }, 'ga', function()
      require('opencode').prompt '@this'
    end, { desc = 'Add to opencode' })
    vim.keymap.set({ 'n', 't' }, '<C-.>', function()
      require('opencode').toggle()
    end, { desc = 'Toggle opencode' })
    vim.keymap.set('n', '<S-C-u>', function()
      require('opencode').command 'session.half.page.up'
    end, { desc = 'opencode half page up' })
    vim.keymap.set('n', '<S-C-d>', function()
      require('opencode').command 'session.half.page.down'
    end, { desc = 'opencode half page down' })
    -- Remap decrement since we use <C-x> for opencode select
    vim.keymap.set('n', '-', '<C-x>', { desc = 'Decrement', noremap = true })
  end,
}
