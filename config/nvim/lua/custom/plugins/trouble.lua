return {
  'folke/trouble.nvim',
  cmd = 'Trouble',
  keys = {
    {
      '<leader>xX',
      '<cmd>Trouble diagnostics toggle<cr>',
      desc = 'Workspace Diagnostics (Trouble)',
    },
    {
      '<leader>xx',
      '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
      desc = 'Buffer Diagnostics (Trouble)',
    },
    {
      '<leader>cs',
      '<cmd>Trouble symbols toggle focus=false<cr>',
      desc = 'Symbols (Trouble)',
    },
    {
      '<leader>cd',
      '<cmd>Trouble lsp_definitions focus=false win.position=right<cr>',
      desc = 'LSP Definitions (Trouble)',
    },
    {
      '<leader>cl',
      '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
      desc = 'LSP Definitions / references / ... (Trouble)',
    },
    {
      '<leader>xL',
      '<cmd>Trouble loclist toggle<cr>',
      desc = 'Location List (Trouble)',
    },
    {
      '<leader>xq',
      '<cmd>Trouble qflist toggle<cr>',
      desc = 'Quickfix List (Trouble)',
    },
  },
  opts = {}, -- for default options, refer to the configuration section for custom setup.
}
