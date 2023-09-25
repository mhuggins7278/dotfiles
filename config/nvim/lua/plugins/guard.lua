return {
  "nvimdev/guard.nvim",
  config = true,
  dependencies = {
    "nvimdev/guard-collection",
  },
  init = function()
    local ft = require('guard.filetype')
    ft('typescript,javascript,typescriptreact,javascriptreact'):fmt({ cmd = 'prettierd', stdin = true, fname = true })
    require('guard').setup({
      -- the only options for the setup function
      fmt_on_save = false,
      -- Use lsp if no formatter was defined for this filetype
      lsp_as_default_formatter = true,
    })
  end
}
