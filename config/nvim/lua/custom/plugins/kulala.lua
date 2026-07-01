return {
  {
    'mistweaverco/kulala.nvim',
    keys = {
      { '<leader>Rs', desc = 'Send request' },
      { '<leader>Ra', desc = 'Send all requests' },
      { '<leader>Rb', desc = 'Open scratchpad' },
    },
    ft = { 'http', 'rest' },
    opts = {
      global_keymaps = true,
      global_keymaps_prefix = '<leader>R',
      -- Override kulala window keymaps that conflict with vim-tmux-navigator
      kulala_keymaps = {
        ['Previous tab'] = { '<S-Tab>', function() require('kulala.ui').show_previous_tab() end, mode = { 'n' } },
        ['Next tab'] = { '<Tab>', function() require('kulala.ui').show_next_tab() end, mode = { 'n' } },
      },
    },
  },
}
