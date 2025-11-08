return { -- Collection of various small independent plugins/modules
  'echasnovski/mini.nvim',
  lazy = false,
  config = function()
    require('mini.ai').setup {
      n_lines = 500,
      custom_textobjects = {
        -- Blocks, conditionals, and loops
        o = require('mini.ai').gen_spec.treesitter {
          a = { '@block.outer', '@conditional.outer', '@loop.outer' },
          i = { '@block.inner', '@conditional.inner', '@loop.inner' },
        },
        -- Functions
        f = require('mini.ai').gen_spec.treesitter {
          a = '@function.outer',
          i = '@function.inner',
        },
        -- Classes
        c = require('mini.ai').gen_spec.treesitter {
          a = '@class.outer',
          i = '@class.inner',
        },
        -- Arguments/Parameters (function args, array/object elements)
        a = require('mini.ai').gen_spec.treesitter {
          a = '@parameter.outer',
          i = '@parameter.inner',
        },
        -- Assignments
        ['='] = require('mini.ai').gen_spec.treesitter {
          a = '@assignment.outer',
          i = '@assignment.inner',
        },
        -- Return statements
        r = require('mini.ai').gen_spec.treesitter {
          a = '@return.outer',
          i = '@return.inner',
        },
        -- Comments
        ['/'] = require('mini.ai').gen_spec.treesitter {
          a = '@comment.outer',
          i = '@comment.outer',
        },
        -- Calls (function calls)
        k = require('mini.ai').gen_spec.treesitter {
          a = '@call.outer',
          i = '@call.inner',
        },
        -- Numbers
        n = require('mini.ai').gen_spec.treesitter {
          a = '@number.inner',
          i = '@number.inner',
        },
        -- Entire buffer
        g = function()
          local from = { line = 1, col = 1 }
          local to = {
            line = vim.fn.line '$',
            col = math.max(vim.fn.getline('$'):len(), 1),
          }
          return { from = from, to = to }
        end,
      },
    }
    require('mini.bracketed').setup()
    -- require('mini.files').setup()
    -- require('mini.indentscope').setup() -- Using snacks.indent instead
    require('mini.operators').setup()
    require('mini.pairs').setup()
    require('mini.splitjoin').setup()
    require('mini.sessions').setup()
    require('mini.surround').setup {
      -- Increase search range to find surroundings more reliably
      n_lines = 50,
      -- Set silent = true to avoid notification spam
      silent = true,
    }

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
}
