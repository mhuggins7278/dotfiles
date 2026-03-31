return {
  'rachartier/tiny-inline-diagnostic.nvim',
  lazy = false,
  priority = 1000,
  init = function()
    local signs = { Error = '󰅚 ', Warn = '󰀪 ', Hint = '󰌶 ', Info = ' ' }

    vim.diagnostic.config {
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = signs.Error,
          [vim.diagnostic.severity.WARN] = signs.Warn,
          [vim.diagnostic.severity.HINT] = signs.Hint,
          [vim.diagnostic.severity.INFO] = signs.Info,
        },
        numhl = {
          [vim.diagnostic.severity.ERROR] = 'DiagnosticSignError',
          [vim.diagnostic.severity.WARN] = 'DiagnosticSignWarn',
          [vim.diagnostic.severity.HINT] = 'DiagnosticSignHint',
          [vim.diagnostic.severity.INFO] = 'DiagnosticSignInfo',
        },
        texthl = {
          [vim.diagnostic.severity.ERROR] = 'DiagnosticSignError',
          [vim.diagnostic.severity.WARN] = 'DiagnosticSignWarn',
          [vim.diagnostic.severity.HINT] = 'DiagnosticSignHint',
          [vim.diagnostic.severity.INFO] = 'DiagnosticSignInfo',
        },
      },
      underline = true,
      update_in_insert = false,
      virtual_text = false,
      severity_sort = true,
      float = {
        border = 'rounded',
        source = true,
        header = '',
        prefix = '',
        focusable = false,
        max_width = 80,
        max_height = 20,
      },
    }
  end,
  opts = {
    options = {
      use_icons_from_diagnostic = true,
      show_source = { enabled = true, if_many = true },
      show_code = false,
      show_related = { enabled = false },
      severity = {
        vim.diagnostic.severity.ERROR,
        vim.diagnostic.severity.WARN,
      },
      override_open_float = true,
    },
  },
}
