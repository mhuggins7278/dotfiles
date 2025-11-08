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
        -- Custom configuration options
        request = {
          skip_ssl_verification = false,
          hooks = {
            encode_url = true,
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
          },
        },
        cookies = {
          enable = true,
        },
        env = {
          enable = true,
          pattern = '.*%.env.*',
        },
        ui = {
          winbar = true,
        },
        highlight = {
          enable = true,
          timeout = 750,
        },
      }

      -- Set up keymaps
      vim.keymap.set('n', '<localleader>rr', '<cmd>Rest run<cr>', { desc = '[R]est [R]un' })
      vim.keymap.set('n', '<localleader>rl', '<cmd>Rest last<cr>', { desc = '[R]est run [L]ast' })
    end,
  },
}
