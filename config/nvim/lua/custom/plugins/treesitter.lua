return { -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  lazy = false, -- main branch does not support lazy loading
  build = ':TSUpdate',
  dependencies = {
    { 'nvim-treesitter/nvim-treesitter-textobjects', branch = 'main' },
  },
  config = function()
    -- Install parsers (runs async on startup)
    require('nvim-treesitter').install {
      'bash',
      'c',
      'html',
      'lua',
      'markdown',
      'markdown_inline',
      'vim',
      'vimdoc',
      'xml',
      'http',
      'javascript',
      'json5',
      'json',
      'graphql',
      'jsdoc',
      'go',
      'typescript',
      'tsx',
    }

    -- Incremental node selection via Neovim 0.12's built-in vim.treesitter._select.
    -- Calls select_parent directly to bypass mini.ai which overrides the 'n' text object.
    -- select_parent from a single-char visual selection returns the smallest containing
    -- named node; subsequent calls expand outward to each parent node.
    local ts_select = require 'vim.treesitter._select'

    vim.keymap.set('n', '<CR>', function()
      vim.cmd 'normal! v'
      ts_select.select_parent(vim.v.count1)
    end, { desc = 'Select treesitter node' })

    vim.keymap.set('x', '<CR>', function()
      ts_select.select_parent(vim.v.count1)
    end, { desc = 'Expand selection to parent node' })

    vim.keymap.set('x', '<BS>', function()
      ts_select.select_child(vim.v.count1)
    end, { desc = 'Shrink selection to child node' })

    -- Textobject swap keymaps (nvim-treesitter-textobjects main API)
    local swap = require 'nvim-treesitter-textobjects.swap'
    vim.keymap.set('n', '<leader>pa', function()
      swap.swap_next '@parameter.inner'
    end, { desc = 'Swap with next parameter' })
    vim.keymap.set('n', '<leader>pA', function()
      swap.swap_previous '@parameter.inner'
    end, { desc = 'Swap with prev parameter' })
    vim.keymap.set('n', '<leader>pf', function()
      swap.swap_next '@function.outer'
    end, { desc = 'Swap with next function' })
    vim.keymap.set('n', '<leader>pF', function()
      swap.swap_previous '@function.outer'
    end, { desc = 'Swap with prev function' })
    vim.keymap.set('n', '<leader>ps', function()
      swap.swap_next '@statement.outer'
    end, { desc = 'Swap with next statement' })
    vim.keymap.set('n', '<leader>pS', function()
      swap.swap_previous '@statement.outer'
    end, { desc = 'Swap with prev statement' })
  end,
}
