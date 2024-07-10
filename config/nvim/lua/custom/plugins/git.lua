return {
  {
    'NeogitOrg/neogit',
    branch = 'master',
    dependencies = {
      'nvim-lua/plenary.nvim', -- required
      'sindrets/diffview.nvim', -- optional - Diff integration

      -- Only one of these is needed, not both.
      'nvim-telescope/telescope.nvim', -- optional
      'ibhagwan/fzf-lua', -- optional
    },
    config = true,
    opts = {
      integrations = {
        diffview = true,
        telescope = true,
      },
    },
    init = function()
      local wk = require 'which-key'
      wk.register {
        ['<leader>gg'] = { '<cmd>Neogit<cr>', '[N]eogit' },
      }
    end,
  },

  -- Here is a more advanced example where we pass configuration
  -- options to `gitsigns.nvim`. This is equivalent to the following lua:
  --    require('gitsigns').setup({ ... })
  --
  -- See `:help gitsigns` to understand what the configuration keys do
  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
    init = function()
      local wk = require 'which-key'
      wk.register {
        ['[h'] = { '<cmd>Gitsigns prev_hunk<cr>', 'Previous hunk' },
        [']h'] = { '<cmd>Gitsigns next_hunk<cr>', 'Next hunk' },
        ['<leader>gp'] = { '<cmd>Gitsigns preview_hunk<cr>', '[P]review hunk' },
        ['<leader>gb'] = { '<cmd>Gitsigns blame_line<cr>', '[B]lame line' },
        ['<leader>gs'] = { '<cmd>Gitsigns stage_hunk<cr>', '[S]tage hunk' },
        ['<leader>gS'] = { '<cmd>Gitsigns stage_buffer<cr>', '[S]tage buffer' },
        ['<leader>gu'] = { '<cmd>Gitsigns undo_stage_hunk<cr>', '[U]nstage hunk' },
        ['<leader>gr'] = { '<cmd>Gitsigns reset_hunk<cr>', '[R]eset hunk' },
        ['<leader>gR'] = { '<cmd>Gitsigns reset_buffer<cr>', '[R]eset buffer' },
      }
    end,
  },
}
