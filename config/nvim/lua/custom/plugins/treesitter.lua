return { -- Tree-sitter parser manager (replaces archived nvim-treesitter core)
  'romus204/tree-sitter-manager.nvim',
  lazy = false,
  dependencies = {
    { 'nvim-treesitter/nvim-treesitter-textobjects', branch = 'main' },
  },
  config = function()
    require('tree-sitter-manager').setup {
      ensure_installed = {
        'bash',
        'c',
        'css',
        'dockerfile',
        'dtd',
        'git_config',
        'git_rebase',
        'gitattributes',
        'gitcommit',
        'gitignore',
        'go',
        'graphql',
        'html',
        'http',
        'javascript',
        'jsdoc',
        'json',
        'json5',
        'lua',
        'markdown',
        'markdown_inline',
        'mermaid',
        'nginx',
        'python',
        'sql',
        'tsx',
        'typescript',
        'vim',
        'vimdoc',
        'xml',
        'yaml',
        'yaml',
        'zsh',
        -- Salesforce / Apex (required by sf.nvim)
        'apex',
        'soql',
        'sosl',
        'sflog',
      },
      highlight = true,
    }

    -- Incremental node selection via Neovim's built-in vim.treesitter._select.
    -- Calls select_parent directly to bypass mini.ai which overrides the 'n' text object.
    -- select_parent from a single-char visual selection returns the smallest containing
    -- named node; subsequent calls expand outward to each parent node.
    -- NOTE: _select is private API but has been stable across 0.10-0.12 and has
    -- no public equivalent yet.
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
