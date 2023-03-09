return {
  "jose-elias-alvarez/null-ls.nvim",
  event = "BufRead",
  config = function()
    local null_ls = require("null-ls")
    null_ls.setup({
      sources = {
        null_ls.builtins.formatting.prettierd,
        null_ls.builtins.diagnostics.eslint_d,
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.diagnostics.sqlfluff.with({
          extra_args = { "--dialect", "tsql" }, -- change to your dialect
        }),
      },
    })
  end,
}
