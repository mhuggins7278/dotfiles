return {
  'themaxmarchuk/tailwindcss-colors.nvim',
  module = 'tailwindcss-colors',
  -- run the setup function after plugin is loaded
  config = function()
    -- pass config options here (or nothing to use defaults)
    require('tailwindcss-colors').setup()
  end,
}
