return {
  'stevearc/conform.nvim',
  config = function(_, opts)
    require('conform').setup {
      notify_on_error = true,
      format_on_save = function(bufnr)
        -- Disable with a global or buffer-local variable
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 500, lsp_fallback = true }
      end,

      formatters_by_ft = {
        ['javascript'] = { 'prettierd' },
        ['javascriptreact'] = { 'prettierd' },
        ['typescript'] = { 'prettierd' },
        ['typescriptreact'] = { 'prettierd' },
        ['vue'] = { 'prettierd' },
        ['css'] = { 'prettierd' },
        ['scss'] = { 'prettierd' },
        ['less'] = { 'prettierd' },
        ['html'] = { 'prettierd' },
        ['json'] = { 'prettierd' },
        ['jsonc'] = { 'prettierd' },
        ['yaml'] = { 'prettierd' },
        ['markdown'] = { 'prettierd' },
        ['markdown.mdx'] = { 'prettierd' },
        ['graphql'] = { 'prettierd' },
        ['handlebars'] = { 'prettierd' },
        -- ['sql'] = { 'sqlfluff' },
        ['lua'] = { 'stylua' },
      },
      formatters = {
        sql_formatter = {
          prepend_args = { '-l', 'tsql' },
        },
        sqlfluff = {
          command = 'sqlfluff',
          args = {
            'format',
            '--dialect',
            'tsql',
            '--disable-progress-bar',
            '-n',
            '-',
          },
          stdin = true,
        },
      },
    }

    vim.api.nvim_create_user_command('FormatDisable', function(args)
      if args.bang then
        -- FormatDisable! will disable formatting just for this buffer
        vim.b.disable_autoformat = true
      else
        vim.g.disable_autoformat = true
      end
    end, {
      desc = 'Disable autoformat-on-save',
      bang = true,
    })
    vim.api.nvim_create_user_command('FormatEnable', function()
      vim.b.disable_autoformat = false
      vim.g.disable_autoformat = false
    end, {
      desc = 'Re-enable autoformat-on-save',
    })
  end,
}
