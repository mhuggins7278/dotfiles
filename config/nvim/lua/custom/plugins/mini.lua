return { -- Collection of various small independent plugins/modules
  'echasnovski/mini.nvim',
  lazy = false,
  config = function()
    require('mini.ai').setup {
      n_lines = 500,
      custom_textobjects = {
        o = require('mini.ai').gen_spec.treesitter({
          a = { '@block.outer', '@conditional.outer', '@loop.outer' },
          i = { '@block.inner', '@conditional.inner', '@loop.inner' },
        }),
        f = require('mini.ai').gen_spec.treesitter({
          a = '@function.outer',
          i = '@function.inner',
        }),
        c = require('mini.ai').gen_spec.treesitter({
          a = '@class.outer',
          i = '@class.inner',
        }),
      },
    }
    require('mini.bracketed').setup()
    -- require('mini.files').setup()
    require('mini.indentscope').setup()
    require('mini.operators').setup()
    require('mini.pairs').setup()
    require('mini.splitjoin').setup()
    require('mini.sessions').setup()
    require('mini.surround').setup()

    -- Simple and easy statusline.
    --  You could remove this setup call if you don't like it,
    --  and try some other statusline plugin
    local statusline = require 'mini.statusline'
    statusline.setup()

    -- You can configure sections in the statusline by overriding their
    -- default behavior. For example, here we set the section for
    -- cursor location to LINE:COLUMN
    ---@diagnostic disable-next-line: duplicate-set-field
    statusline.section_location = function()
      return '%2l:%-2v'
    end
    ---@diagnostic disable-next-line: duplicate-set-field
    statusline.section_git = function()
      return ''
    end
  end,
  keys = {
    { '<leader>o', '<cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<cr>', desc = 'MiniFiles' },
  },
}
