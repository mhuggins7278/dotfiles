return {
  {
    'vhyrro/luarocks.nvim',
    priority = 1000,
    config = true,
    opts = {
      rocks = { 'lua-curl', 'nvim-nio', 'mimetypes', 'xml2lua' },
    },
  },
  {
    'rest-nvim/rest.nvim',
    ft = 'http',
    dependencies = { 'luarocks.nvim' },
    config = function()
      -- Configure rest.nvim via vim.g
      ---@type rest.Opts
      vim.g.rest_nvim = {
        -- Custom dynamic variables (optional)
        -- custom_dynamic_variables = {},
        request = {
          skip_ssl_verification = false,
          hooks = {
            encode_url = true,
            -- Sets User-Agent header when empty (set to "" to disable)
            user_agent = 'rest.nvim',
            -- Set Content-Type header when empty and body is provided
            set_content_type = true,
          },
        },
        response = {
          hooks = {
            decode_url = true,
            format = true,
          },
        },
        clients = {
          curl = {
            statistics = {
              { id = 'time_total', winbar = 'take', title = 'Time taken' },
              { id = 'size_download', winbar = 'size', title = 'Download size' },
            },
            opts = {
              -- Add --compressed when Accept-Encoding includes gzip
              set_compressed = false,
              -- Certificates for specific domains (optional)
              -- certificates = {},
            },
          },
        },
        cookies = {
          enable = true,
          path = vim.fs.joinpath(vim.fn.stdpath 'data' --[[@as string]], 'rest-nvim.cookies'),
        },
        env = {
          enable = true,
          pattern = '.*%.env.*',
        },
        ui = {
          winbar = true,
          keybinds = {
            prev = 'H',
            next = 'L',
          },
        },
        highlight = {
          enable = true,
          timeout = 750,
        },
      }

      -- Set up keymaps
      vim.keymap.set('n', '<localleader>rr', '<cmd>Rest run<cr>', { desc = '[R]est [R]un' })
      vim.keymap.set('n', '<localleader>rl', '<cmd>Rest last<cr>', { desc = '[R]est run [L]ast' })
      vim.keymap.set('n', '<localleader>re', '<cmd>Rest env select<cr>', { desc = '[R]est [E]nv select' })
    end,
  },
}
