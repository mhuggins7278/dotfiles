return {
  'christoomey/vim-tmux-navigator',
  cond = vim.env.TMUX ~= nil,
  lazy = false,
  keys = {
    { '<C-h>', '<cmd>TmuxNavigateLeft<cr>' },
    { '<C-j>', '<cmd>TmuxNavigateDown<cr>' },
    { '<C-k>', '<cmd>TmuxNavigateUp<cr>' },
    { '<C-l>', '<cmd>TmuxNavigateRight<cr>' },
    { '<C-\\>', '<cmd>TmuxNavigatePrevious<cr>' },
  },
}
