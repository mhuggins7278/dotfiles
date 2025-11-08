return { -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  dependencies = {
    'nvim-treesitter/nvim-treesitter-textobjects',
  },
  config = function()
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter`

    ---@diagnostic disable-next-line: missing-fields
    require('nvim-treesitter.configs').setup {
      ensure_installed = {
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
      },
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<CR>', -- Enter in normal mode to start selection
          node_incremental = '<CR>', -- Keep pressing Enter to expand
          scope_incremental = '<S-TAB>', -- Shift+Tab to expand to scope
          node_decremental = '<TAB>', -- Tab to shrink (in visual mode after selection started)
        },
      },
      textobjects = {
        swap = {
          enable = true,
          swap_next = {
            ['<leader>pa'] = '@parameter.inner', -- swap parameters/argument with next
            ['<leader>pf'] = '@function.outer', -- swap function with next
            ['<leader>ps'] = '@statement.outer', -- swap statement with next (includes const declarations)
          },
          swap_previous = {
            ['<leader>pA'] = '@parameter.inner', -- swap parameters/argument with prev
            ['<leader>pF'] = '@function.outer', -- swap function with prev
            ['<leader>pS'] = '@statement.outer', -- swap statement with prev
          },
        },
      },
    }

    -- There are additional nvim-treesitter modules that you can use to interact
    -- with nvim-treesitter. You should go explore a few and see what interests you:
    --
    --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
    --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
    --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  end,
}
