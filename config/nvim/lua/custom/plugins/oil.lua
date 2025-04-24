return {
  'stevearc/oil.nvim',
  enabled = false,
  opts = {
    columns = {
      'icon',
      'permissions',
      'size',
      'mtime',
    },
    view_options = {
      show_hidden = true,
    },
    win_options = {
      signcolumn = 'yes',
    },
  },
  -- Optional dependencies
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  init = function()
    local wk = require 'which-key'
    wk.add {
      { '<leader>o', '<cmd> Oil<cr>', desc = '[E]xplorer' },
    }
  end,
}
