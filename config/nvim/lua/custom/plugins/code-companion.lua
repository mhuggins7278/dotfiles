return {
  'olimorris/codecompanion.nvim',
  config = true,
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  keys = {
    { '<leader>ct', '<cmd>CodeCompanionChat Toggle<cr>', desc = '[T]oggle Chat' },
    { '<leader>cc', '<cmd>CodeCompanion /commit <cr>', desc = '[C]ommit Staged' },
  },
  opts = {},
}
