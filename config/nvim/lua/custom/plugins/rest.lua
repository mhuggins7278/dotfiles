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
    init = function()
      local wk = require 'which-key'
      wk.add {
        { '<localleader>rr', '<cmd>Rest run<cr>', desc = '[R]est run' },
        { '<localleader>rl', '<cmd>Rest last<cr>', desc = '[R]est rerun last' },
      }

      ---rest.nvim default configuration
      ---@class rest.Config
      local default_config = {
        ---@type table<string, fun():string> Table of custom dynamic variables
        custom_dynamic_variables = {},
        ---@class rest.Config.Request
        request = {
          ---@type boolean Skip SSL verification, useful for unknown certificates
          skip_ssl_verification = false,
          ---Default request hooks
          ---@class rest.Config.Request.Hooks
          hooks = {
            ---@type boolean Encode URL before making request
            encode_url = true,
          },
        },
        ---@class rest.Config.Response
        response = {
          ---@class rest.Config.Response.Hooks
          hooks = {
            ---@type boolean Decode the request URL segments on response UI to improve readability
            decode_url = true,
            ---@type boolean Format the response body using `gq` command
            format = true,
          },
        },
        ---@class rest.Config.Clients
        clients = {
          ---@class rest.Config.Clients.Curl
          curl = {
            ---Statistics to be shown, takes cURL's `--write-out` flag variables
            ---See `man curl` for `--write-out` flag
            ---@type table<string,RestStatisticsStyle>
            statistics = {
              time_total = { winbar = 'take', title = 'Time taken' },
              size_download = { winbar = 'size', title = 'Download size' },
            },
          },
        },
        ---@class rest.Config.Cookies
        cookies = {
          ---@type boolean Whether enable cookies support or not
          enable = true,
          ---@type string Cookies file path
          path = vim.fs.joinpath(vim.fn.stdpath 'data' --[[@as string]], 'rest-nvim.cookies'),
        },
        ---@class rest.Config.Env
        env = {
          ---@type boolean
          enable = true,
          ---@type string
          pattern = '.*%.env.*',
        },
        ---@class rest.Config.UI
        ui = {
          ---@type boolean Whether to set winbar to result panes
          winbar = true,
          ---@class rest.Config.UI.Keybinds
          keybinds = {
            ---@type string Mapping for cycle to previous result pane
            prev = 'H',
            ---@type string Mapping for cycle to next result pane
            next = 'L',
            ---@type string Close the results paint
            quit = 'q',
          },
        },
        ---@class rest.Config.Highlight
        highlight = {
          ---@type boolean Whether current request highlighting is enabled or not
          enable = true,
          ---@type number Duration time of the request highlighting in milliseconds
          timeout = 750,
        },
      }
    end,
  },
}
