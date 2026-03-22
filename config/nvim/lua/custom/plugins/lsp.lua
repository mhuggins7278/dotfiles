return { -- LSP Configuration & Plugins
  'neovim/nvim-lspconfig',
  dependencies = {
    -- Automatically install LSPs and related tools to stdpath for neovim
    'williamboman/mason.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    'saghen/blink.cmp',
    { 'j-hui/fidget.nvim', opts = {} },
    { 'b0o/schemastore.nvim', lazy = true, version = false },
  },
  config = function()
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
      virtual_text = {
        severity = { min = vim.diagnostic.severity.WARN },
        source = 'if_many',
        prefix = '●',
        spacing = 4,
        format = function(diagnostic)
          local message = diagnostic.message
          if #message > 80 then
            return message:sub(1, 77) .. '...'
          end
          return message
        end,
      },
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

    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),

      callback = function(event)
        -- NOTE: Remember that lua is a real programming language, and as such it is possible
        -- to define small helper and utility functions so you don't have to repeat yourself
        -- many times.
        --
        -- In this case, we create a function that lets us more easily define mappings specific
        -- for LSP related items. It sets the mode, buffer and description for us each time.
        local map = function(keys, func, desc, mode)
          mode = mode or 'n'
          vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end
        local mapx = function(keys, func, desc)
          vim.keymap.set('x', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        -- Jump to the definition of the word under your cursor.
        --  This is where a variable was first declared, or where a function is defined, etc.
        --  To jump back, press <C-T>.
        map('gd', function()
          Snacks.picker.lsp_definitions()
        end, '[G]oto [D]efinition')

        -- Find references for the word under your cursor.
        map('gr', function()
          Snacks.picker.lsp_references()
        end, '[G]oto [R]eferences')

        -- Jump to the implementation of the word under your cursor.
        --  Useful when your language has ways of declaring types without an actual implementation.
        map('gI', function()
          Snacks.picker.lsp_implementations()
        end, '[G]oto [I]mplementation')

        -- WARN: This is not Goto Definition, this is Goto Declaration.
        --  For example, in C this would take you to the header
        map('gD', function()
          Snacks.picker.lsp_declarations()
        end, '[G]oto [D]eclaration')

        -- Fuzzy find all the symbols in your current document.
        --  Symbols are things like variables, functions, types, etc.
        map('<leader>ds', function()
          Snacks.picker.lsp_symbols()
        end, '[D]ocument [S]ymbols')

        -- Fuzzy find all the symbols in your current workspace
        --  Similar to document symbols, except searches over your whole project.
        map('<leader>ws', function()
          Snacks.picker.lsp_dynamic_workspace_symbols()
        end, '[W]orkspace [S]ymbols')

        -- Rename the variable under your cursor
        --  Most Language Servers support renaming across files, etc.
        map('<leader>cr', vim.lsp.buf.rename, '[C]ode [R]ename')

        -- Execute a code action, usually your cursor needs to be on top of an error
        -- or a suggestion from your LSP for this to activate.
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
        mapx('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

        -- Organize imports
        map('<leader>co', function()
          vim.lsp.buf.code_action {
            apply = true,
            context = {
              only = { 'source.organizeImports' },
              diagnostics = {},
            },
          }
        end, '[C]ode [O]rganize Imports')

        -- Opens a popup that displays documentation about the word under your cursor
        --  See `:help K` for why this keymap
        map('K', vim.lsp.buf.hover, 'Hover Documentation')

        -- Signature help (changed from <C-k> to avoid conflict with window navigation)
        map('<C-s>', vim.lsp.buf.signature_help, 'Signature Help', { 'n', 'i' })

        -- Jump to the type of the word under your cursor.
        --  Useful when you're not sure what type a variable is and you want to see
        --  the definition of its *type*, not where it was *defined*.
        map('<leader>D', function()
          Snacks.picker.lsp_type_definitions()
        end, 'Type [D]efinition')

        -- Diagnostic navigation
        map('[d', vim.diagnostic.goto_prev, 'Previous [D]iagnostic')
        map(']d', vim.diagnostic.goto_next, 'Next [D]iagnostic')
        map('<leader>e', vim.diagnostic.open_float, 'Show diagnostic [E]rror')
        map('<leader>q', vim.diagnostic.setloclist, 'Diagnostic [Q]uickfix list')

        -- Get LSP client for additional setup
        local client = vim.lsp.get_client_by_id(event.data.client_id)

        -- Enable inlay hints by default for buffers that support it
        if client and client.server_capabilities.inlayHintProvider then
          vim.lsp.inlay_hint.enable(false, { bufnr = event.buf })
        end

        -- The following two autocommands are used to highlight references of the
        -- word under your cursor when your cursor rests there for a little while.
        --    See `:help CursorHold` for information about when this is executed
        --
        -- When you move your cursor, the highlights will be cleared (the second autocommand).
        if client and client.server_capabilities.documentHighlightProvider then
          local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })

          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
            end,
          })
        end
      end,
    })

    -- Set global capabilities for all LSP servers.
    -- blink.cmp extends the default capabilities with completion item support.
    vim.lsp.config('*', {
      capabilities = vim.tbl_deep_extend(
        'force',
        vim.lsp.protocol.make_client_capabilities(),
        require('blink.cmp').get_lsp_capabilities({}, false),
        -- Ensure snippet support is enabled for HTML/JSON
        { textDocument = { completion = { completionItem = { snippetSupport = true } } } }
      ),
    })

    -- Ensure the servers and tools are installed via Mason.
    --  To check the current status of installed tools and/or manually install
    --  other tools, you can run :Mason (press `g?` for help in this menu).
    require('mason').setup()
    require('mason-tool-installer').setup {
      ensure_installed = {
        -- LSP servers
        'biome',
        'gopls',
        'html-lsp',
        'json-lsp',
        'lua-language-server',
        'oxlint',
        'tailwindcss-language-server',
        'taplo',
        'terraform-ls',
        'vtsls',
        'yaml-language-server',
        -- Formatters and tools
        'delve',
        'gofumpt',
        'goimports',
        'gomodifytags',
        'impl',
        'jq',
        'prettierd',
        'sql-formatter',
        'sqlfluff',
        'stylua',
      },
    }

    -- Enable all configured LSP servers.
    -- Each server's config lives in lsp/<server_name>.lua and is automatically
    -- discovered from the runtimepath. nvim-lspconfig provides the default
    -- cmd/filetypes/root_dir for servers not fully specified here.
    vim.lsp.enable {
      'lua_ls',
      'gopls',
      'vtsls',
      'tailwindcss',
      'biome',
      'oxlint',
      'terraformls',
      'yamlls',
      'html',
      'taplo',
      'jsonls',
    }
  end,
}
