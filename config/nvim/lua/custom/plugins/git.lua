return {
  {
    'NeogitOrg/neogit',
    branch = 'master',
    dependencies = {
      'nvim-lua/plenary.nvim', -- required
      'sindrets/diffview.nvim', -- optional - Diff integration
    },
    config = true,
    opts = {
      integrations = {
        diffview = true,
      },
    },
    init = function()
      local wk = require 'which-key'
      wk.add {
        { '<leader>gg', '<cmd>Neogit<cr>', desc = '[N]eogit' },
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
      wk.add {
        { '<leader>gR', '<cmd>Gitsigns reset_buffer<cr>', desc = '[R]eset buffer' },
        { '<leader>ga', '<cmd>Gitsigns stage_buffer<cr>', desc = 'Stage [A]ll (buffer)' },
        -- { '<leader>gb', '<cmd>Gitsigns blame_line<cr>', desc = '[B]lame line' },
        { '<leader>gp', '<cmd>Gitsigns preview_hunk<cr>', desc = '[P]review hunk' },
        { '<leader>gr', '<cmd>Gitsigns reset_hunk<cr>', desc = '[R]eset hunk' },
        { '<leader>gh', '<cmd>Gitsigns stage_hunk<cr>', desc = 'Stage [H]unk' },
        { '<leader>gu', '<cmd>Gitsigns undo_stage_hunk<cr>', desc = '[U]nstage hunk' },
        { '[h', '<cmd>Gitsigns prev_hunk<cr>', desc = 'Previous hunk' },
        { ']h', '<cmd>Gitsigns next_hunk<cr>', desc = 'Next hunk' },
      }
    end,
  },
}
