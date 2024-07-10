return {
  'yioneko/nvim-vtsls',
  lazy = true,
  opts = {},
  config = function(_, opts)
    require('vtsls').config(opts)
  end,
}
