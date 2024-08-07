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
      require('rest-nvim').setup {
        keybinds = {
          {
            '<localleader>rr',
            '<cmd>Rest run<cr>',
            'Run request under the cursor',
          },
          {
            '<localleader>rl',
            '<cmd>Rest run last<cr>',
            'Re-run latest request',
          },
        },
      }
    end,
  },
}
