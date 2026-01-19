return {
  -- Diffview for better conflict resolution and diffs
  {
    'sindrets/diffview.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
    config = function()
      require('diffview').setup {
        enhanced_diff_hl = true, -- Better syntax highlighting in diffs
        view = {
          -- Configure the layout and behavior of different types of views.
          merge_tool = {
            -- Config for conflicted files in diff views during a merge or rebase.
            layout = 'diff3_mixed', -- 3-way diff with base in middle
            disable_diagnostics = true,
            winbar_info = true, -- Show conflict info in winbar
          },
        },
        file_panel = {
          win_config = {
            width = 35,
          },
        },
        hooks = {
          -- Show helpful message when opening conflicts
          diff_buf_read = function()
            local git_dir = vim.fn.system('git rev-parse --git-dir 2>/dev/null'):gsub('\n', '')
            if git_dir == '' then
              return
            end

            local rebase_merge = git_dir .. '/rebase-merge'
            local rebase_apply = git_dir .. '/rebase-apply'

            if vim.fn.isdirectory(rebase_merge) == 1 or vim.fn.isdirectory(rebase_apply) == 1 then
              vim.notify('🔄 REBASE MODE: OURS=target branch, THEIRS=your changes', vim.log.levels.INFO)
            end
          end,
        },
        keymaps = {
          view = {
            -- Conflict resolution mappings
            { 'n', '<leader>co', '<Cmd>DiffviewConflictChooseOurs<CR>', { desc = 'Choose OURS (left)' } },
            { 'n', '<leader>ct', '<Cmd>DiffviewConflictChooseTheirs<CR>', { desc = 'Choose THEIRS (right)' } },
            { 'n', '<leader>cb', '<Cmd>DiffviewConflictChooseBase<CR>', { desc = 'Choose BASE (ancestor)' } },
            { 'n', '<leader>ca', '<Cmd>DiffviewConflictChooseAll<CR>', { desc = 'Choose ALL (keep both)' } },
            { 'n', '<leader>cx', '<Cmd>DiffviewConflictListQf<CR>', { desc = 'Send to quickfix list' } },
            { 'n', '[x', '<Cmd>DiffviewConflictPrev<CR>', { desc = 'Previous conflict' } },
            { 'n', ']x', '<Cmd>DiffviewConflictNext<CR>', { desc = 'Next conflict' } },
          },
        },
      }
    end,
    init = function()
      local wk = require 'which-key'
      wk.add {
        { '<leader>gv', '<cmd>DiffviewOpen<cr>', desc = 'Diff[V]iew Open' },
        { '<leader>gc', '<cmd>DiffviewClose<cr>', desc = 'Diff[V]iew [C]lose' },
        { '<leader>gm', '<cmd>DiffviewOpen origin/main...HEAD<cr>', desc = 'Diff vs [M]ain' },
        { '<leader>gH', '<cmd>DiffviewFileHistory %<cr>', desc = 'File [H]istory' },
        { '<leader>gF', '<cmd>DiffviewFileHistory<cr>', desc = 'Branch [F]ile History' },
      }
    end,
  },

  {
    'NeogitOrg/neogit',
    branch = 'master',
    dependencies = {
      'nvim-lua/plenary.nvim', -- required
      'sindrets/diffview.nvim', -- optional - Diff integration
    },
    config = function()
      local neogit = require 'neogit'
      neogit.setup {
        integrations = {
          diffview = true,
        },
        -- Better rebase editor experience
        disable_hint = false,
        disable_signs = false,
        graph_style = 'unicode',
      }
    end,
    init = function()
      local wk = require 'which-key'
      wk.add {
        { '<leader>gg', '<cmd>Neogit<cr>', desc = '[N]eogit' },
        { '<leader>gir', '<cmd>Neogit rebase<cr>', desc = '[R]ebase [I]nteractive' },
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
        { '<leader>gp', '<cmd>Gitsigns preview_hunk<cr>', desc = '[P]review hunk' },
        { '<leader>gr', '<cmd>Gitsigns reset_hunk<cr>', desc = '[R]eset hunk' },
        { '<leader>gh', '<cmd>Gitsigns stage_hunk<cr>', desc = 'Stage [H]unk' },
        { '<leader>gu', '<cmd>Gitsigns undo_stage_hunk<cr>', desc = '[U]nstage hunk' },
        { '[h', '<cmd>Gitsigns prev_hunk<cr>', desc = 'Previous hunk' },
        { ']h', '<cmd>Gitsigns next_hunk<cr>', desc = 'Next hunk' },
        { '[c', '<cmd>Gitsigns prev_hunk<cr>', desc = 'Previous conflict/change' },
        { ']c', '<cmd>Gitsigns next_hunk<cr>', desc = 'Next conflict/change' },
      }
    end,
  },
}
