-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.augment_workspace_folders = { vim.fn.expand '~' .. '/github/glg/', vim.fn.expand '~' .. '/github/mhuggins7278/' }

-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2

vim.opt.shiftround = true

vim.opt.conceallevel = 1

-- You can also add relative line numbers, for help with jumping.
--  Experiment for yourself to see if you like it!
-- vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.opt.clipboard = 'unnamedplus'

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or capital in qsearch
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Disable smart indent so treesitter indent works better
vim.opt.smartindent = false

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'
vim.opt.guifont = 'FiraCode Nerd Font:h14'

-- Decrease update time
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = false

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 999

vim.opt.termguicolors = true
vim.opt.colorcolumn = '80'

vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
vim.opt.shortmess:append 'c'

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.keymap.set('n', '<leader>y', '<cmd>let @*=expand("%:~:.")<cr>', { desc = '[Y]ank Relatvie File Path' })
-- Diagnostic keymaps
vim.keymap.set('n', '[d', function()
  vim.diagnostic.jump { count = -1 }
end, { desc = 'Go to previous [D]iagnostic message' })

vim.keymap.set('n', ']d', function()
  vim.diagnostic.jump { count = 1 }
end, { desc = 'Go to next [D]iagnostic message' })

vim.keymap.set('n', '[e', function()
  vim.diagnostic.jump { count = -1, severity = vim.diagnostic.severity.ERROR }
end, { desc = 'Go to previous [E]rror message' })

vim.keymap.set('n', ']e', function()
  vim.diagnostic.jump { count = 1, severity = vim.diagnostic.severity.ERROR }
end, { desc = 'Go to previous [E]rror message' })

vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

vim.keymap.set('i', 'jj', '<Esc>', { silent = true })
vim.keymap.set('n', '<leader>w', ':w<CR>', { desc = 'Save file', remap = true, silent = true })
vim.keymap.set('n', '<leader>i', function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(nil))
end, { desc = 'Toggle [I]nlay Hints', remap = true, silent = true })

--center cursor after various movement commands
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')
-- vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
-- vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")

vim.keymap.set('n', '{', '{zz')
vim.keymap.set('n', '}', '}zz')

--move line up and down
vim.keymap.set('n', 'J', 'mzJ`z', { desc = 'Join Line Below' })
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move Selection Up' })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move Selection Down' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
local octo_group = vim.api.nvim_create_augroup('octo_mappings', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'octo',
  callback = function()
    vim.keymap.set('i', '@', '@<C-x><C-o>', { silent = true, buffer = true })
    vim.keymap.set('i', '#', '#<C-x><C-o>', { silent = true, buffer = true })
  end,
  group = octo_group,
})

local epi_directory = vim.fn.expand '~' .. '/github/glg/epiquery-templates/'
local sl_directory = vim.fn.expand '~' .. '/github/glg/streamliner/'

-- Create an autocommand group
vim.api.nvim_create_augroup('MustacheToFileType', { clear = true })

-- Create an autocommand
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  group = 'MustacheToFileType',
  pattern = '*.mustache',
  callback = function()
    local current_file = vim.fn.expand '%:p'
    if string.find(current_file, epi_directory, 1, true) then
      vim.bo.filetype = 'sql'
    end
  end,
})

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  group = 'MustacheToFileType',
  pattern = '*.mustache',
  callback = function()
    local current_file = vim.fn.expand '%:p'
    if string.find(current_file, sl_directory, 1, true) then
      vim.bo.filetype = 'html'
    end
  end,
})

-- vim.api.nvim_create_autocmd('BufWritePre', {
--   group = 'vtsls',
--   pattern = { '*.ts', '*.js', '*.tsx', '*.jsx' },
--   callback = OrganizeImports,
-- })

-- vim.api.nvim_create_autocmd({ 'FileType' }, {
--   desc = 'Enable completions for dadbod/sql',
--   group = vim.api.nvim_create_augroup('dadbad', {}),
--   pattern = { 'sql', 'mysql', 'plsql' },
--   callback = function()
--     vim.schedule(require('cmp').setup.buffer { sources = { { name = 'dadbod' } } })
--   end,
-- })
vim.api.nvim_create_autocmd('BufWritePost', {
  pattern = { 'aerospace.toml' },
  command = "execute 'silent !aerospace reload-config'",
})
vim.api.nvim_create_autocmd('BufWritePost', {
  pattern = { '*tmux.conf' },
  command = "execute 'silent !tmux source <afile> --silent'",
})

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins, you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.

---@diagnostic disable-next-line: missing-fields
require('lazy').setup {
  spec = {
    -- NOTE: Plugins can be added with a link (or for a github repo: 'owner/repo' link).
    'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
    { 'augmentcode/augment.vim', cmd = 'Augment' },

    -- NOTE: Plugins can also be added by using a table,
    -- with the first argument being the link and the following
    -- keys can be used to configure plugin behavior/loading/etc.
    --
    -- Use `opts = {}` to force a plugin to be loaded.
    --
    --  This is equivalent to:
    --    require('Comment').setup({})

    -- "gc" to comment visual regions/lines
    { 'numToStr/Comment.nvim', opts = {} },

    -- NOTE: Plugins can also be configured to run lua code when they are loaded.
    --
    -- This is often very useful to both group configuration, as well as handle
    -- lazy loading plugins that don't need to be loaded immediately at startup.
    --
    -- For example, in the following configuration, we use:
    --  event = 'VimEnter'
    --
    -- which loads which-key before all the UI elements are loaded. Events can be
    -- normal autocommands events (`:help autocmd-events`).
    --
    -- Then, because we use the `config` key, the configuration only runs
    -- after the plugin has been loaded:
    --  config = function() ... end

    { -- Useful plugin to show you pending keybinds.
      'folke/which-key.nvim',
      event = 'VimEnter', -- Sets the loading event to 'VimEnter'
      config = function() -- This is the function that runs, AFTER loading
        require('which-key').setup()

        -- Document existing key chains
        require('which-key').add {
          { '<leader>c', group = '[C]ode' },
          -- { '<leader>c_', hidden = true },
          -- { '<leader>d', group = '[D]ocument' },
          -- { '<leader>d_', hidden = true },
          { '<leader>g', group = '[G]it' },
          { '<leader>g_', hidden = true },
          { '<leader>r', group = '[R]ename' },
          { '<leader>r_', hidden = true },
          { '<leader>s', group = '[S]earch' },
          { '<leader>s_', hidden = true },
          { '<leader>w', group = '[W]orkspace' },
          { '<leader>w_', hidden = true },
        }
      end,
    },

    -- NOTE: Plugins can specify dependencies.
    --
    -- The dependencies are proper plugin specifications as well - anything
    -- you do for a plugin at the top level, you can do for a dependency.
    --
    -- Use the `dependencies` key to specify the dependencies of a particular plugin

    { -- LSP Configuration & Plugins
      'neovim/nvim-lspconfig',
      dependencies = {
        -- Automatically install LSPs and related tools to stdpath for neovim
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
        'WhoIsSethDaniel/mason-tool-installer.nvim',

        -- Useful status updates for LSP.
        -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
        { 'j-hui/fidget.nvim', opts = {} },
      },
      config = function()
        vim.diagnostic.config {
          signs = true,
          underline = true,
          update_in_insert = false,
          virtual_text = false,
        }
        local signs = { Error = '󰅚 ', Warn = '󰀪 ', Hint = '󰌶 ', Info = ' ' }
        for type, icon in pairs(signs) do
          local hl = 'DiagnosticSign' .. type
          vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
        end
        -- Brief Aside: **What is LSP?**
        --
        -- LSP is an acronym you've probably heard, but might not understand what it is.
        --
        -- LSP stands for Language Server Protocol. It's a protocol that helps editors
        -- and language tooling communicate in a standardized fashion.
        --
        -- In general, you have a "server" which is some tool built to understand a particular
        -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc). These Language Servers
        -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
        -- processes that communicate with some "client" - in this case, Neovim!
        --
        -- LSP provides Neovim with features like:
        --  - Go to definition
        --  - Find references
        --  - Autocompletion
        --  - Symbol Search
        --  - and more!
        --
        -- Thus, Language Servers are external tools that must be installed separately from
        -- Neovim. This is where `mason` and related plugins come into play.
        --
        -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
        -- and elegantly composed help section, `:help lsp-vs-treesitter`

        --  This function gets run when an LSP attaches to a particular buffer.
        --    That is to say, every time a new file is opened that is associated with
        --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
        --    function will be executed to configure the current buffer
        vim.api.nvim_create_autocmd('LspAttach', {
          group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),

          callback = function(event)
            -- NOTE: Remember that lua is a real programming language, and as such it is possible
            -- to define small helper and utility functions so you don't have to repeat yourself
            -- many times.
            --
            -- In this case, we create a function that lets us more easily define mappings specific
            -- for LSP related items. It sets the mode, buffer and description for us each time.
            local map = function(keys, func, desc)
              vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
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
              Snacks.picker.lsp_implemntations()
            end, '[G]oto [I]mplementation')

            -- Jump to the type of the word under your cursor.
            --  Useful when you're not sure what type a variable is and you want to see
            --  the definition of its *type*, not where it was *defined*.
            map('gD', function()
              Snacks.picker.lsp_type_definitions()
            end, 'Type [D]efinition')

            -- Fuzzy find all the symbols in your current document.
            --  Symbols are things like variables, functions, types, etc.
            -- map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

            -- Fuzzy find all the symbols in your current workspace
            --  Similar to document symbols, except searches over your whole project.
            map('<leader>ws', function()
              Snacks.picker.lsp_dynamic_workspace_symbols()
            end, '[W]orkspace [S]ymbols')

            -- Rename the variable under your cursor
            --  Most Language Servers support renaming across files, etc.
            -- map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

            -- Execute a code action, usually your cursor needs to be on top of an error
            -- or a suggestion from your LSP for this to activate.
            map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
            mapx('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
            map('<leader>cr', vim.lsp.buf.rename, '[C]ode [R]ename')
            --Call organzie imports

            -- Opens a popup that displays documentation about the word under your cursor
            --  See `:help K` for why this keymap
            map('K', vim.lsp.buf.hover, 'Hover Documentation')

            -- WARN: This is not Goto Definition, this is Goto Declaration.
            --  For example, in C this would take you to the header
            map('<leader>D', function()
              Snacks.picker.lsp_declarations()
            end, '[G]oto [D]eclaration')

            -- The following two autocommands are used to highlight references of the
            -- word under your cursor when your cursor rests there for a little while.
            --    See `:help CursorHold` for information about when this is executed
            --
            -- When you move your cursor, the highlights will be cleared (the second autocommand).
            local client = vim.lsp.get_client_by_id(event.data.client_id)
            if client and client.server_capabilities.documentHighlightProvider then
              vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                buffer = event.buf,
                callback = vim.lsp.buf.document_highlight,
              })

              vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                buffer = event.buf,
                callback = vim.lsp.buf.clear_references,
              })
            end
          end,
        })

        -- LSP servers and clients are able to communicate to each other what features they support.
        --  By default, Neovim doesn't support everything that is in the LSP Specification.
        --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
        --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

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
          gopls = {
            settings = {
              gopls = {
                gofumpt = true,
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
                hints = {
                  assignVariableTypes = true,
                  compositeLiteralFields = true,
                  compositeLiteralTypes = true,
                  constantValues = true,
                  functionTypeParameters = true,
                  parameterNames = true,
                  rangeVariableTypes = true,
                },
                analyses = {
                  fieldalignment = true,
                  nilness = true,
                  unusedparams = true,
                  unusedwrite = true,
                  useany = true,
                },
                usePlaceholders = true,
                completeUnimported = true,
                staticcheck = true,
                directoryFilters = { '-.git', '-.vscode', '-.idea', '-.vscode-test', '-node_modules' },
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
            root_dir = function(fname)
              local root_pattern = require('lspconfig').util.root_pattern('tailwind.config.cjs', 'tailwind.config.js', 'postcss.config.ts')
              return root_pattern(fname)
            end,
          },

          eslint = {
            settings = {
              useFlatConfig = false, -- set if using flat config
              experimental = {
                useFlatConfig = nil, -- option not in the latest eslint-lsp
              },
            },
          },
          terraformls = {},
          yamlls = {},
          html = {},
          taplo = {},
          jsonls = {},
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
              complete_function_calls = true,
              vtsls = {
                enableMoveToFileCodeAction = true,
                autoUseWorkspaceTsdk = true,
                experimental = {
                  maxInlayHintLength = 30,
                  completion = {
                    enableServerSideFuzzyMatch = true,
                  },
                },
              },
              typescript = {
                updateImportsOnFileMove = { enabled = 'always' },
                suggest = {
                  completeFunctionCalls = true,
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
          'delve',
          'eslint-lsp',
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

        ---@diagnostic disable-next-line: missing-fields
        require('mason-lspconfig').setup {
          handlers = {
            function(server_name)
              local server = servers[server_name] or {}
              -- This handles overriding only values explicitly passed
              -- by the server configuration above. Useful when disabling
              -- certain features of an LSP (for example, turning off formatting for tsserver)
              server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
              require('lspconfig')[server_name].setup(server)
            end,
          },
        }
      end,
    },
    { -- Autocompletion
      'hrsh7th/nvim-cmp',
      event = 'InsertEnter',
      dependencies = {
        -- Snippet Engine & its associated nvim-cmp source
        {
          'L3MON4D3/LuaSnip',
          tag = 'v2.3.0',
          run = 'make install_jsregexp',
        },
        'saadparwaiz1/cmp_luasnip',

        -- Adds other completion capabilities.
        --  nvim-cmp does not ship with all sources by default. They are split
        --  into multiple repos for maintenance purposes.
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-path',
        'onsails/lspkind.nvim',
        'hrsh7th/cmp-buffer',

        -- If you want to add a bunch of pre-configured snippets,
        --    you can use this plugin to help you. It even has snippets
        --    for various frameworks/libraries/etc. but you will have to
        --    set up the ones that are useful for you.
        'rafamadriz/friendly-snippets',
      },
      config = function()
        -- See `:help cmp`
        local cmp = require 'cmp'
        local luasnip = require 'luasnip'
        luasnip.config.setup {}
        local lspkind = require 'lspkind'
        lspkind.init()
        require('luasnip.loaders.from_vscode').lazy_load()

        cmp.setup {
          preselect = cmp.PreselectMode.None,
          snippet = {
            expand = function(args)
              luasnip.lsp_expand(args.body)
            end,
          },
          completion = { completeopt = 'menu,menuone,noinsert' },
          window = {
            completion = cmp.config.window.bordered(),
            documentation = cmp.config.window.bordered(),
          },
          ---@diagnostic disable-next-line: missing-fields
          formatting = {
            format = lspkind.cmp_format {
              mode = 'text_symbol',
              maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
              -- can also be a function to dynamically calculate max width such as
              -- maxwidth = function() return math.floor(0.45 * vim.o.columns) end,
              ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
              show_labelDetails = true, -- show labelDetails in menu. Disabled by default
              symbol_map = { Codeium = '', Supermaven = '' },
              menu = {
                path = '[Path]',
                buffer = '[Buffer]',
                nvim_lsp = '[LSP]',
                luasnip = '[LuaSnip]',
                lazydev = '[Lua]',
                copilot = '[Copilot]',
              },

              -- The function below will be called before any actual modifications from lspkind
              -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
            },
          },

          -- For an understanding of why these mappings were
          -- chosen, you will need to read `:help ins-completion`
          --
          -- No, but seriously. Please read `:help ins-completion`, it is really good!
          mapping = cmp.mapping.preset.insert {
            -- Select the [n]ext item
            ['<C-n>'] = cmp.mapping.select_next_item(),
            -- Select the [p]revious item
            ['<C-p>'] = cmp.mapping.select_prev_item(),

            -- Accept ([y]es) the completion.
            --  This will auto-import if your LSP supports it.
            --  This will expand snippets if the LSP sent a snippet.
            ['<C-y>'] = cmp.mapping.confirm { select = true },

            -- Manually trigger a completion from nvim-cmp.
            --  Generally you don't need this, because nvim-cmp will display
            --  completions whenever it has completion options available.
            ['<C-Space>'] = cmp.mapping.complete {},

            -- Think of <c-l> as moving to the right of your snippet expansion.
            --  So if you have a snippet that's like:
            --  function $name($args)
            --    $body
            --  end
            --
            -- <c-l> will move you to the right of each of the expansion locations.
            -- <c-h> is similar, except moving you backwards.
            ['<C-j>'] = cmp.mapping(function()
              if luasnip.expand_or_locally_jumpable() then
                luasnip.expand_or_jump()
              end
            end, { 'i', 's' }),
            ['<C-k>'] = cmp.mapping(function()
              if luasnip.locally_jumpable(-1) then
                luasnip.jump(-1)
              end
            end, { 'i', 's' }),
          },
          sources = {
            { name = 'nvim_lsp' },
            { name = 'lazydev' },
            { name = 'copilot' },
            { name = 'luasnip' },
            { name = 'path' },
            { name = 'buffer' },
          },
        }
        cmp.setup.filetype({ 'sql' }, { sources = { { name = 'vim-dadbod-completion' }, { name = 'buffer' } } })
      end,
    },

    {
      'catppuccin/nvim',
      name = 'catppuccin',
      priority = 1000,
      config = function()
        require('catppuccin').setup {
          flavour = 'auto',
          background = { -- :h background
            light = 'latte',
            dark = 'mocha',
          },
          transparent_background = true,
          term_colors = true,
          default_integrations = true,
          integrations = {
            alpha = true,
            avante = true,
            cmp = true,
            copilot_vim = true,
            dadbod_ui = true,
            dap = true,
            dap_ui = true,
            diffview = true,
            fidget = true,
            gitsigns = true,
            harpoon = true,
            lsp_trouble = true,
            indent_blankline = true,
            markdown = true,
            mason = true,
            mini = {
              enabled = true,
              indentscope_color = '',
            },
            native_lsp = {
              enabled = true,
              virtual_text = {
                errors = { 'italic' },
                hints = { 'italic' },
                warnings = { 'italic' },
                information = { 'italic' },
              },
              underlines = {
                errors = { 'undercurl' },
                hints = { 'undercurl' },
                warnings = { 'undercurl' },
                information = { 'undercurl' },
              },
              inlay_hints = {
                background = true,
              },
            },
            neogit = true,
            neotest = true,
            noice = true,
            notify = true,
            nvimtree = true,
            octo = true,
            telescope = true,
            treesitter = true,
            treesitter_context = true,
            ts_rainbow2 = true,
            which_key = true,
          },
          styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
            comments = { 'italic' }, -- Change the style of comments
            conditionals = { 'italic' },
          },
        }
        vim.cmd.colorscheme 'catppuccin-mocha'
      end,
    },

    -- The following two comments only work if you have downloaded the kickstart repo, not just copy pasted the
    -- init.lua. If you want these files, they are in the repository, so you can just download them and
    -- put them in the right spots if you want.

    -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for kickstart
    --
    --  Here are some example plugins that I've included in the kickstart repository.
    --  Uncomment any of the lines below to enable them (you will need to restart nvim).
    --
    require 'kickstart.plugins.debug',

    -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
    --    This is the easiest way to modularize your config.
    --
    --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
    --    For additional information, see `:help lazy.nvim-lazy.nvim-structuring-your-plugins`
    { import = 'custom.plugins' },

    {
      'rachartier/tiny-inline-diagnostic.nvim',
      event = 'VeryLazy', -- Or `LspAttach`
      priority = 1000, -- needs to be loaded in first
      config = function()
        require('tiny-inline-diagnostic').setup()
      end,
    },
  },
  checker = { enabled = true, notify = true, frequency = 3600 },
}

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
