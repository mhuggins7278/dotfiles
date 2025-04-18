return {
  'michaelrommel/nvim-silicon',
  lazy = true,
  cmd = 'Silicon',
  config = function()
    require('silicon').setup {
      -- Configuration here, or leave empty to use defaults
      font = 'Monaspace Radon=24',
      to_clipboard = true,
      theme = 'Catppuccin Mocha',
    }
  end,
}
