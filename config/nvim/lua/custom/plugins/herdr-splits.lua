return {
  'lmilojevicc/herdr-splits.nvim',
  cond = vim.env.HERDR_ENV == '1',
  event = 'VeryLazy',
  commit = 'c58bfdf01520845583e0033c11c56fc9d21a5424',
  config = function()
    require('herdr-splits').setup {
      at_edge = 'stop',
      nav_at_edge = 'stop',
      auto_sync_herdr = false,
      resize_keys = {
        left = '<C-M-h>',
        down = '<C-M-j>',
        up = '<C-M-k>',
        right = '<C-M-l>',
      },
    }
  end,
  keys = {
    { '<C-h>', function() require('herdr-splits').move_cursor_left() end, desc = 'Navigate left' },
    { '<C-j>', function() require('herdr-splits').move_cursor_down() end, desc = 'Navigate down' },
    { '<C-k>', function() require('herdr-splits').move_cursor_up() end, desc = 'Navigate up' },
    { '<C-l>', function() require('herdr-splits').move_cursor_right() end, desc = 'Navigate right' },
    { '<C-M-h>', function() require('herdr-splits').resize_left() end, desc = 'Resize left' },
    { '<C-M-j>', function() require('herdr-splits').resize_down() end, desc = 'Resize down' },
    { '<C-M-k>', function() require('herdr-splits').resize_up() end, desc = 'Resize up' },
    { '<C-M-l>', function() require('herdr-splits').resize_right() end, desc = 'Resize right' },
  },
}
