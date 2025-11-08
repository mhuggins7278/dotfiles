return {
  'folke/noice.nvim',
  event = 'VeryLazy',
  enabled = true,
  opts = {
    presets = {
      bottom_search = false, -- use a classic bottom cmdline for search
      command_palette = false, -- position the cmdline and popupmenu together
      long_message_to_split = true, -- long messages will be sent to a split
      inc_rename = true, -- enables an input dialog for inc-rename.nvim
      lsp_doc_border = true, -- add a border to hover docs and signature help
    },
    lsp = {
      progress = {
        enabled = true,
        format = 'lsp_progress',
        format_done = 'lsp_progress_done',
        throttle = 1000 / 30, -- frequency to update lsp progress message
        view = 'mini',
      },
      -- override markdown rendering so that plugins use Treesitter
      override = {
        ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
        ['vim.lsp.util.stylize_markdown'] = true,
      },
      hover = {
        enabled = true,
        silent = false, -- set to true to not show a message if hover is not available
      },
      signature = {
        enabled = true,
        auto_open = {
          enabled = true,
          trigger = true, -- Automatically show signature help when typing a trigger character from the LSP
          luasnip = true, -- Will open signature help when jumping to Luasnip insert nodes
          throttle = 50, -- Debounce lsp signature help request by 50ms
        },
      },
    },
    routes = {
      {
        filter = {
          event = 'msg_show',
          kind = '',
          find = 'written',
        },
        opts = { skip = true },
      },
      {
        filter = {
          event = 'msg_show',
          kind = '',
          find = 'more lines',
        },
        opts = { skip = true },
      },
      {
        filter = {
          event = 'msg_show',
          kind = '',
          find = 'fewer lines',
        },
        opts = { skip = true },
      },
    },
    views = {
      cmdline_popup = {
        position = {
          row = 5,
          col = '50%',
        },
        size = {
          width = 60,
          height = 'auto',
        },
      },
      popupmenu = {
        relative = 'editor',
        position = {
          row = 8,
          col = '50%',
        },
        size = {
          width = 60,
          height = 10,
        },
        border = {
          style = 'rounded',
          padding = { 0, 1 },
        },
        win_options = {
          winhighlight = { Normal = 'Normal', FloatBorder = 'DiagnosticInfo' },
        },
      },
    },
  },
  keys = {
    {
      '<leader>sn',
      function()
        require('noice').cmd 'history'
      end,
      desc = 'Noice History',
    },
    {
      '<leader>snl',
      function()
        require('noice').cmd 'last'
      end,
      desc = 'Noice Last Message',
    },
    {
      '<leader>snd',
      function()
        require('noice').cmd 'dismiss'
      end,
      desc = 'Dismiss All Notifications',
    },
    {
      '<leader>sne',
      function()
        require('noice').cmd 'errors'
      end,
      desc = 'Noice Errors',
    },
    {
      '<c-f>',
      function()
        if not require('noice.lsp').scroll(4) then
          return '<c-f>'
        end
      end,
      silent = true,
      expr = true,
      desc = 'Scroll forward',
      mode = { 'i', 'n', 's' },
    },
    {
      '<c-b>',
      function()
        if not require('noice.lsp').scroll(-4) then
          return '<c-b>'
        end
      end,
      silent = true,
      expr = true,
      desc = 'Scroll backward',
      mode = { 'i', 'n', 's' },
    },
  },
  dependencies = {
    'MunifTanjim/nui.nvim',
  },
}
