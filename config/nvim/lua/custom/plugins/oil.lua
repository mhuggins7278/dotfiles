return {
  'stevearc/oil.nvim',
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
  },
  -- Optional dependencies
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  init = function()
    local wk = require 'which-key'
    wk.register {
      ['<leader>o'] = { '<cmd> Oil<cr>', '[E]xplorer' },
    }
  end,
}
