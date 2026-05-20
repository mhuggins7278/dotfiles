return {
  'folke/zen-mode.nvim',
  opts = {
    window = {
      width = 0.60,
      options = {
        number = true,
        relativenumber = true,
      },
    },
  },
  keys = { { '<leader>z', '<cmd>ZenMode<cr>', desc = '+[z]enMode' } },
}
