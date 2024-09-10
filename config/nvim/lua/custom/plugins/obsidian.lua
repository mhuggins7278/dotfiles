return {
  'epwalsh/obsidian.nvim',
  -- lazy = true,
  -- event = { 'BufReadPre ' .. vim.fn.expand '~' .. '/github/mhuggins7278/notes/**.md' },
  -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand':
  -- event = { "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md" },
  dependencies = {
    -- Required.
    'nvim-lua/plenary.nvim',

    -- Optional, for completion.
    'hrsh7th/nvim-cmp',

    -- Optional, for search and quick-switch functionality.
    'nvim-telescope/telescope.nvim',
  },
  opts = {
    dir = '~/github/mhuggins7278/notes', -- no need to call 'vim.fn.expand' here
    daily_notes = {
      -- Optional, if you keep daily notes in a separate directory.
      folder = 'dailies',
      -- Optional, if you want to change the date format for daily notes.
      date_format = '%Y-%m-%d',
    },
    completion = {
      -- Set to false to disable completion.
      nvim_cmp = true,
      -- Trigger completion at 2 chars.
      min_chars = 2,
    },
    ui = {
      enable = false, -- set to false to disable all additional syntax features
      -- Define how various check-boxes are displayed
    },
    mappings = {
      -- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
      ['gf'] = {
        action = function()
          return require('obsidian').util.gf_passthrough()
        end,
        opts = { noremap = false, expr = true, buffer = true },
      },
      -- Toggle check-boxes.
      ['<leader>ch'] = {
        action = function()
          return require('obsidian').util.toggle_checkbox()
        end,
        opts = { buffer = true },
      },
      -- Smart action depending on context, either follow link or toggle checkbox.
      ['<cr>'] = {
        action = function()
          return require('obsidian').util.smart_action()
        end,
        opts = { buffer = true, expr = true },
      },
    },
    -- see below for full list of options 👇
  },
}
