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
    }

    -- Incremental node selection (replaces nvim-treesitter.configs incremental_selection)
    vim.keymap.set('n', '<CR>', function()
      local node = vim.treesitter.get_node()
      if not node then
        return
      end
      local sr, sc, er, ec = node:range()
      vim.api.nvim_win_set_cursor(0, { er + 1, math.max(0, ec - 1) })
      vim.cmd 'normal! v'
      vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
    end, { desc = 'Select treesitter node' })

    vim.keymap.set('x', '<CR>', function()
      local pos = vim.api.nvim_win_get_cursor(0)
      local node = vim.treesitter.get_node { pos = { pos[1] - 1, pos[2] } }
      if not node then
        return
      end
      local parent = node:parent()
      if not parent then
        return
      end
      local sr, sc, er, ec = parent:range()
      vim.api.nvim_win_set_cursor(0, { er + 1, math.max(0, ec - 1) })
      vim.cmd 'normal! o'
      vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
    end, { desc = 'Expand selection to parent node' })

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
