return { -- LSP Configuration & Plugins
  'neovim/nvim-lspconfig',
  dependencies = {
    -- Automatically install LSPs and related tools to stdpath for neovim
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    'saghen/blink.cmp',
    { 'j-hui/fidget.nvim', opts = {} },
    { 'b0o/schemastore.nvim', lazy = true, version = false },
  },
  config = function()
    local signs = { Error = '󰅚 ', Warn = '󰀪 ', Hint = '󰌶 ', Info = ' ' }
    local ok, util = pcall(require, 'lspconfig.util')
    if not ok then
      vim.notify 'lspconfig.util could not be loaded'
      return
    end
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

    -- LSP servers and clients are able to communicate to each other what features they support.
    --  By default, Neovim doesn't support everything that is in the LSP Specification.
    --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
    --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend('force', capabilities, require('blink.cmp').get_lsp_capabilities({}, false))

    -- Enable snippet support for HTML/JSON
    capabilities.textDocument.completion.completionItem.snippetSupport = true

    -- Enable the following language servers
    --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
    --
    --  Add any additional override configuration in the following tables. Available keys are:
    --  - cmd (table): Override the default command used to start the server
    --  - filetypes (table): Override the default list of associated filetypes for the server
    --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
    --  - settings (table): Override the default settings passed when initializing the server.
    --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
    local servers = {
      -- clangd = {},
      lua_ls = {
        settings = {
          Lua = {
            runtime = { version = 'LuaJIT' },
            workspace = {
              checkThirdParty = false,
              library = {
                '${3rd}/luv/library',
                unpack(vim.api.nvim_get_runtime_file('', true)),
              },
            },
            completion = {
              callSnippet = 'Replace',
            },
            hint = {
              enable = true,
            },
            telemetry = { enable = false },
          },
        },
      },
      gopls = {
        settings = {
          gopls = {
            gofumpt = true,
            -- Performance optimizations
            diagnosticsDelay = '250ms',
            symbolMatcher = 'FastFuzzy',
            symbolScope = 'workspace',
            -- Completion
            matcher = 'Fuzzy',
            completionBudget = '100ms',
            experimentalPostfixCompletions = true,
            -- Documentation
            linkTarget = 'pkg.go.dev',
            hoverKind = 'FullDocumentation',
            -- Code lenses
            codelenses = {
              gc_details = false,
              generate = true,
              regenerate_cgo = true,
              run_govulncheck = true,
              test = true,
              tidy = true,
              upgrade_dependency = true,
              vendor = true,
            },
            -- Inlay hints
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
            -- Analyses
            analyses = {
              -- fieldalignment removed in gopls v0.17.0, hover over struct fields instead
              nilness = true,
              shadow = true,
              unusedparams = true,
              unusedvariable = true,
              unusedwrite = true,
              useany = true,
            },
            usePlaceholders = true,
            completeUnimported = true,
            staticcheck = true,
            directoryFilters = { '-.git', '-.vscode', '-.idea', '-.vscode-test', '-node_modules', '-**/node_modules' },
            semanticTokens = true,
          },
        },
      },
      -- pyright = {},
      -- rust_analyzer = {},
      -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
      --
      -- Some languages (like typescript) have entire language plugins that can be useful:
      --    https://github.com/pmizio/typescript-tools.nvim
      --
      -- But for many setups, the LSP (`tsserver`) will work just fine
      --
      tailwindcss = {
        root_dir = util.root_pattern(
          'tailwind.config.js',
          'tailwind.config.cjs',
          'tailwind.config.mjs',
          'tailwind.config.ts',
          'postcss.config.js',
          'postcss.config.ts'
        ),
        settings = {
          tailwindCSS = {
            includeLanguages = {
              typescript = 'javascript',
              typescriptreact = 'javascript',
              ['typescript.tsx'] = 'typescriptreact',
              ['javascript.jsx'] = 'javascriptreact',
            },
            experimental = {
              classRegex = {
                'tw`([^`]*)',
                'tw="([^"]*)',
                'tw={"([^"}]*)',
                'tw\\.\\w+`([^`]*)',
                { 'clsx\\(([^)]*)\\)', "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                { 'classnames\\(([^)]*)\\)', "'([^']*)'" },
                { 'cva\\(([^)]*)\\)', '["\'`]([^"\'`]*).*?["\'`]' },
              },
            },
            lint = {
              cssConflict = 'warning',
              invalidApply = 'error',
              invalidConfigPath = 'error',
              invalidScreen = 'error',
              invalidTailwindDirective = 'error',
              invalidVariant = 'error',
              recommendedVariantOrder = 'warning',
            },
            validate = true,
            colorDecorators = true,
            suggestions = true,
            showPixelEquivalents = true,
            rootFontSize = 16,
          },
        },
      },

      biome = {
        root_dir = util.root_pattern 'biome.json',
        single_file_support = false,
      },

      oxlint = {},

      terraformls = {
        cmd = { 'terraform-ls', 'serve' },
        filetypes = { 'terraform', 'tf', 'hcl' },
        root_dir = util.root_pattern('.terraform', '.git'),
        settings = {
          terraform = {
            validation = {
              enableEnhancedValidation = true,
            },
            experimentalFeatures = {
              validateOnSave = true,
              prefillRequiredFields = true,
            },
          },
        },
      },

      yamlls = {
        settings = {
          yaml = {
            schemaStore = {
              enable = true,
              url = 'https://www.schemastore.org/api/json/catalog.json',
            },
            schemas = require('schemastore').yaml.schemas(),
            format = {
              enable = true,
              singleQuote = false,
              bracketSpacing = true,
            },
            validate = true,
            hover = true,
            completion = true,
            customTags = {
              '!vault',
              '!encrypted/pkcs1-oaep scalar',
              '!reference sequence',
            },
          },
          redhat = {
            telemetry = {
              enabled = false,
            },
          },
        },
      },

      html = {
        settings = {
          html = {
            format = {
              enable = true,
              wrapLineLength = 120,
              wrapAttributes = 'auto',
              templating = true,
              unformatted = 'wbr',
              contentUnformatted = 'pre,code,textarea',
              endWithNewline = false,
              preserveNewLines = true,
              maxPreserveNewLines = 2,
            },
            validate = {
              scripts = true,
              styles = true,
            },
            autoClosingTags = true,
            suggest = {
              html5 = true,
            },
            hover = {
              documentation = true,
              references = true,
            },
          },
        },
      },

      taplo = {
        settings = {
          taplo = {
            formatter = {
              alignEntries = false,
              alignComments = true,
              arrayTrailingComma = true,
              arrayAutoExpand = true,
              arrayAutoCollapse = true,
              compactArrays = true,
              compactInlineTables = false,
              columnWidth = 80,
              indentTables = false,
              trailingNewline = true,
              reorderKeys = false,
              allowedBlankLines = 2,
            },
            schema = {
              enabled = true,
              repositoryEnabled = true,
              repositoryUrl = 'https://taplo.tamasfe.dev/schema_index.json',
            },
          },
        },
      },

      jsonls = {
        settings = {
          json = {
            schemas = require('schemastore').json.schemas(),
            validate = { enable = true },
            format = {
              enable = true,
            },
          },
        },
      },

      vtsls = {
        -- explicitly add default filetypes, so that we can extend
        -- them in related extras
        filetypes = {
          'javascript',
          'javascriptreact',
          'javascript.jsx',
          'typescript',
          'typescriptreact',
          'typescript.tsx',
        },
        settings = {
          vtsls = {
            enableMoveToFileCodeAction = true,
            autoUseWorkspaceTsdk = true,
            experimental = {
              maxInlayHintLength = 30,
              completion = {
                enableServerSideFuzzyMatch = true,
                entriesLimit = 100,
              },
              plugins = {},
            },
          },
          -- Top-level typescript/javascript settings for vtsls
          typescript = {
            updateImportsOnFileMove = { enabled = 'always' },
            suggest = {
              completeFunctionCalls = true,
              autoImports = true,
              paths = true,
              includeCompletionsForImportStatements = true,
            },
            preferences = {
              includePackageJsonAutoImports = 'auto',
              autoImportFileExcludePatterns = {
                '**/node_modules/**',
                '**/.git/**',
                '**/dist/**',
                '**/build/**',
              },
              preferTypeOnlyAutoImports = true,
              renameMatchingJsxTags = true,
              useAliasesForRenames = true,
            },
            inlayHints = {
              enumMemberValues = { enabled = true },
              functionLikeReturnTypes = { enabled = true },
              parameterNames = { enabled = 'literals' },
              parameterTypes = { enabled = true },
              propertyDeclarationTypes = { enabled = true },
              variableTypes = { enabled = false },
            },
          },
          javascript = {
            updateImportsOnFileMove = { enabled = 'always' },
            suggest = {
              completeFunctionCalls = true,
              autoImports = true,
              paths = true,
              includeCompletionsForImportStatements = true,
            },
            preferences = {
              includePackageJsonAutoImports = 'auto',
              autoImportFileExcludePatterns = {
                '**/node_modules/**',
                '**/.git/**',
                '**/dist/**',
                '**/build/**',
              },
              renameMatchingJsxTags = true,
              useAliasesForRenames = true,
            },
            inlayHints = {
              enumMemberValues = { enabled = true },
              functionLikeReturnTypes = { enabled = true },
              parameterNames = { enabled = 'literals' },
              parameterTypes = { enabled = true },
              propertyDeclarationTypes = { enabled = true },
              variableTypes = { enabled = false },
            },
          },
        },
      },
    }

    -- Ensure the servers and tools above are installed
    --  To check the current status of installed tools and/or manually install
    --  other tools, you can run
    --    :Mason
    --
    --  You can press `g?` for help in this menu
    require('mason').setup()

    -- You can add other tools here that you want Mason to install
    -- for you, so that they are available from within Neovim.
    local ensure_installed = vim.tbl_keys(servers or {})
    vim.list_extend(ensure_installed, {
      'biome',
      'delve',
      'gofumpt',
      'goimports',
      'gomodifytags',
      'gopls',
      'impl',
      'jq',
      'prettierd',
      'sql-formatter',
      'sqlfluff',
      'stylua',
      'vtsls',
    })
    require('mason-tool-installer').setup { ensure_installed = ensure_installed }

    -- Use new vim.lsp.config API for Neovim 0.11+
    -- Configure each server with the new API before mason sets them up
    for server_name, server_config in pairs(servers) do
      local config = vim.tbl_deep_extend('force', {
        capabilities = capabilities,
      }, server_config)

      -- Use the new vim.lsp.config() API to set defaults
      vim.lsp.config(server_name, config)
    end

    ---@diagnostic disable-next-line: missing-fields
    require('mason-lspconfig').setup {
      ensure_installed = vim.tbl_keys(servers),
      handlers = {
        function(server_name)
          -- Enable the server with vim.lsp.enable
          -- The config has already been set above
          vim.lsp.enable(server_name)
        end,
      },
    }
  end,
}
