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
        return { timeout_ms = 1000, lsp_format = 'fallback' }
      end,

      formatters_by_ft = {
        ['javascript'] = { 'biome', 'oxfmt', 'prettierd', stop_after_first = true },
        ['javascriptreact'] = { 'biome', 'oxfmt', 'prettierd', stop_after_first = true },
        ['typescript'] = { 'biome', 'oxfmt', 'prettierd', stop_after_first = true },
        ['typescriptreact'] = { 'biome', 'oxfmt', 'prettierd', stop_after_first = true },
        ['vue'] = { 'oxfmt', 'prettierd', stop_after_first = true },
        ['css'] = { 'oxfmt', 'prettierd', stop_after_first = true },
        ['scss'] = { 'oxfmt', 'prettierd', stop_after_first = true },
        ['less'] = { 'oxfmt', 'prettierd', stop_after_first = true },
        ['html'] = { 'oxfmt', 'prettierd', stop_after_first = true },
        ['json'] = { 'oxfmt', 'prettierd', stop_after_first = true },
        ['jsonc'] = { 'oxfmt', 'prettierd', stop_after_first = true },
        ['yaml'] = { 'oxfmt', 'prettierd', stop_after_first = true },
        ['markdown'] = { 'oxfmt', 'prettierd', stop_after_first = true },
        ['markdown.mdx'] = { 'oxfmt', 'prettierd', stop_after_first = true },
        ['graphql'] = { 'oxfmt', 'prettierd', stop_after_first = true },
        ['handlebars'] = { 'oxfmt', 'prettierd', stop_after_first = true },
        ['lua'] = { 'stylua' },
        ['go'] = { 'goimports-reviser', 'gofumpt' },
      },
      formatters = {
        biome = {
          cwd = require('conform.util').root_file { 'biome.json' },
          require_cwd = true,
        },
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
