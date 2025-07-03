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
vim.opt.guicursor = ''

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
vim.opt.scrolloff = 8

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

    { 'dundalek/bloat.nvim', cmd = 'Bloat' },

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
            blink_cmp = true,
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
