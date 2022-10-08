--[[
lvim is the global options object

Linters should be
filled in as strings with either
a global executable or a path to
an executable
]]
-- THESE ARE EXAMPLE CONFIGS FEEL FREE TO CHANGE TO WHATEVER YOU WANT

-- general
lvim.log.level = "warn"
lvim.format_on_save = false
-- lvim.colorscheme = "tokyonight"
-- vim.g.tokyonight_style = "storm"
-- vim.background = "dark"
local opt = vim.opt
opt.foldlevel = 20
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.termguicolors = true
opt.showtabline = 0



local silent = { silent = true }
--Thank you ThePrimeagen for these
--Center screen after moving up and down by half
vim.api.nvim_set_keymap("n", "<C-d>", "<C-d>zz", silent)
vim.api.nvim_set_keymap("n", "<C-u>", "<C-u>zz", silent)
--paste in visual mode without overwriting register
vim.api.nvim_set_keymap("v", "<leader>r", '"_dP', silent)
--delete without overwriting register
vim.api.nvim_set_keymap("n", "<leader>d", '"_d', silent)
vim.api.nvim_set_keymap("v", "<leader>d", '"_d', silent)
vim.api.nvim_set_keymap("i", "jj", "<ESC>", silent)
vim.api.nvim_set_keymap("i", "jk", "<ESC>", silent)
vim.api.nvim_set_keymap("n", "gp", "<cmd>lua vim.lsp.buf.hover()<CR>", silent)

--harpoon key maps
vim.api.nvim_set_keymap("n", "<C-h>", '<cmd>lua require("harpoon.mark").add_file()<CR>', silent)
vim.api.nvim_set_keymap("n", "<C-j>", '<cmd>lua require("harpoon.ui").nav_file(1)<CR>', silent)
vim.api.nvim_set_keymap("n", "<C-k>", '<cmd>lua require("harpoon.ui").nav_file(2)<CR>', silent)
vim.api.nvim_set_keymap("n", "<C-l>", '<cmd>lua require("harpoon.ui").nav_file(3)<CR>', silent)
vim.api.nvim_set_keymap("n", "<C-;>", '<cmd>lua require("harpoon.ui").nav_file(4)<CR>', silent)
vim.api.nvim_set_keymap("n", "<C-n>", '<cmd>lua require("harpoon.ui").toggle_quick_menu()<CR>', silent)


vim.g.copilot_no_tab_map = true
vim.g.copilot_assume_mapped = true
vim.g.copilot_tab_fallback = ""
vim.api.nvim_set_keymap("i", "<C-f>", 'copilot#Accept("<CR>")', { silent = true, expr = true })

vim.opt.cmdheight = 1
vim.cmd([[
  set nocompatible
  filetype off
  syntax enable
  filetype plugin indent on
  set relativenumber 
  set colorcolumn=80
  set statusline=""
]])

lvim.builtin.breadcrumbs.active = true


vim.g.copilot_node_command = "/Users/MHuggins/.nvm/versions/node/v16.15.1/bin/node"

-- to disable icons and use a minimalist setup, uncomment the following
-- lvim.use_icons = false

-- keymappings [view all the defaults by pressing <leader>Lk]
lvim.leader = "space"
-- add your own keymapping
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"
lvim.builtin.bufferline.active = false
-- unmap a default keymapping
-- lvim.keys.normal_mode["<C-Up>"] = false
-- edit a default keymapping
-- lvim.keys.normal_mode["<C-q>"] = ":q<cr>"

-- Change Telescope navigation to use j and k for navigation and n and p for history in both input and normal mode.
-- we use protected-mode (pcall) just in case the plugin wasn't loaded yet.
-- local _, actions = pcall(require, "telescope.actions")

--   -- for input mode
--   i = {
--     ["<C-j>"] = actions.move_selection_next,
--     ["<C-k>"] = actions.move_selection_previous,
--     ["<C-n>"] = actions.cycle_history_next,
--     ["<C-p>"] = actions.cycle_history_prev,
--   },
--   -- for normal mode
--   n = {
--     ["<C-j>"] = actions.move_selection_next,
--     ["<C-k>"] = actions.move_selection_previous,
--   },
-- }

-- Use which-key to add extra bindings with the leader-key prefix
lvim.builtin.which_key.mappings["s"]["w"] = {
	"<cmd>Telescope grep_string<CR>",
	"Current Word",
}
lvim.builtin.which_key.mappings["t"] = {
	"<cmd>Telescope colorscheme<CR>",
	"Color Scheme",
}

lvim.builtin.which_key.mappings["z"] = {
	"<cmd>redir @*> | echon join([expand('%'),  line('.')], ':') | redir END<CR>",
	"Copy file:line",
}

lvim.builtin.which_key.mappings["b"] = {
	"<cmd>Telescope buffers<CR>",
	"List Buffers",
}

lvim.builtin.which_key.mappings["o"] = {
	name = "Octo",
	i = { "<cmd>Octo issue list glg/Service-Excellence<CR>", "List Issues" },
}
-- lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }
-- lvim.builtin.which_key.mappings["t"] = {
--   name = "+Trouble",
--   r = { "<cmd>Trouble lsp_references<cr>", "References" },
--   f = { "<cmd>Trouble lsp_definitions<cr>", "Definitions" },
--   d = { "<cmd>Trouble document_diagnostics<cr>", "Diagnostics" },
--   q = { "<cmd>Trouble quickfix<cr>", "QuickFix" },
--   l = { "<cmd>Trouble loclist<cr>", "LocationList" },
--   w = { "<cmd>Trouble workspace_diagnostics<cr>", "Wordspace Diagnostics" },
-- }

-- TODO: User Config for predefined plugins
-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.notify.active = true
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "right"
lvim.builtin.nvimtree.setup.sync_root_with_cwd = false
lvim.builtin.lualine.sections.lualine_z = { "filesize" }
lvim.builtin.terminal.size = 40

-- if you don't want all the parsers change this to a table of the ones you want
lvim.builtin.treesitter.ensure_installed = {
	"bash",
	"c",
	"javascript",
	"json",
	"lua",
	"python",
	"typescript",
	"tsx",
	"css",
	"rust",
	"java",
	"yaml",
	"html",
	"svelte",
	"go",
}

lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enabled = true
lvim.builtin.treesitter.autotag.enable = true
lvim.transparent_window = true
-- generic LSP settings

-- lvim.lsp.automatic_servers_installation = true

-- ---configure a server manually. !!Requires `:LvimCacheReset` to take effect!!
-- ---see the full default list `:lua print(vim.inspect(lvim.lsp.automatic_configuration.skipped_servers))`
-- vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "pyright" })
-- local opts = {} -- check the lspconfig documentation for a list of all possible options
-- require("lvim.lsp.manager").setup("pyright", opts)

-- ---remove a server from the skipped list, e.g. eslint, or emmet_ls. !!Requires `:LvimCacheReset` to take effect!!
-- ---`:LvimInfo` lists which server(s) are skiipped for the current filetype
-- vim.tbl_map(function(server)
--   return server ~= "emmet_ls"
-- end, lvim.lsp.automatic_configuration.skipped_servers)

-- -- you can set a custom on_attach function that will be used for all the language servers
-- -- See <https://github.com/neovim/nvim-lspconfig#keybindings-and-completion>
-- lvim.lsp.on_attach_callback = function(client, bufnr)
--   local function buf_set_option(...)
--     vim.api.nvim_buf_set_option(bufnr, ...)
--   end
--   --Enable completion triggered by <c-x><c-o>
--   buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
-- end

-- -- set a formatter, this will override the language server formatting capabilities (if it exists)
local formatters = require("lvim.lsp.null-ls.formatters")
formatters.setup({
	{
		-- each formatter accepts a list of options identical to https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#Configuration
		command = "prettier_d_slim",
		---@usage arguments to pass to the formatter
		-- these cannot contain whitespaces, options such as `--line-width 80` become either `{'--line-width', '80'}` or `{'--line-width=80'}`
		extra_args = { "--print-with", "100" },
		---@usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
		filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact", "astro" },
	},
	{ command = "stylua", filetypes = { "lua" } },
})

-- set additional linters
local linters = require("lvim.lsp.null-ls.linters")
linters.setup({
	{
		command = "eslint_d",
		filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	},
	{
		command = "luacheck",
		filetypes = { "lua" },
	},
})

linters.setup({
	command = "luacheck",
	filetypes = { "lua" },
})

-- Additional Plugins
lvim.plugins = {
	{ "nvim-treesitter/nvim-treesitter-textobjects" },
	{ "ThePrimeagen/harpoon" },
	{ "uga-rosa/ccc.nvim" },
	{ "github/copilot.vim" },

	{ "projekt0n/github-nvim-theme" },
	{ "Mofiqul/dracula.nvim" },
	{
		"folke/trouble.nvim",
		cmd = "TroubleToggle",
	},
	{ "kdheepak/lazygit.nvim" },
	{ "kchmck/vim-coffee-script" },
	{ "ellisonleao/gruvbox.nvim" },
	{
		"folke/todo-comments.nvim",
		requires = "nvim-lua/plenary.nvim",
		config = function()
			require("todo-comments").setup({
				-- your configuration comes here
				-- or leave it empty to use the default settings
				-- refer to the configuration section below
			})
		end,
	},
	{ "0x100101/lab.nvim", run = "cd js && npm ci", requires = { "nvim-lua/plenary.nvim" } },
	{
		"iamcco/markdown-preview.nvim",
		run = function()
			vim.fn["mkdp#util#install"]()
		end,
	},
	{ "ellisonleao/glow.nvim" },
	{
		"tpope/vim-surround",
		keys = { "c", "d", "y" },
		setup = function()
			vim.o.timeoutlen = 500
		end,
	},
	{ "p00f/nvim-ts-rainbow" },
	{ "catppuccin/vim" },
	{
		"pwntester/octo.nvim",
		requires = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
			"kyazdani42/nvim-web-devicons",
		},
		config = function()
			require("octo").setup()
		end,
	},
	"David-Kunz/jester",
	{
		"https://git.sr.ht/~whynothugo/lsp_lines.nvim",
		config = function()
			require("lsp_lines").setup()
		end,
	},
	{ "ruifm/gitlinker.nvim", requires = "nvim-lua/plenary.nvim" },
	{
		"zbirenbaum/copilot.lua",
		event = { "VimEnter" },
		config = function()
			vim.defer_fn(function()
				require("copilot").setup({
					plugin_manager_path = get_runtime_dir() .. "/site/pack/packer",
				})
			end, 100)
		end,
	},

	{ "zbirenbaum/copilot-cmp", after = { "copilot.lua", "nvim-cmp" } },
}

-- Can not be placed into the config method of the plugins.
lvim.builtin.cmp.formatting.source_names["copilot"] = "(Copilot)"
table.insert(lvim.builtin.cmp.sources, 1, { name = "copilot" })
require("nvim-treesitter.configs").setup({
	highlight = {
		-- ...
	},
	-- ...
	rainbow = {
		enable = true,
		-- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
		extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
		max_file_lines = nil, -- Do not enable for files with more than n lines, int
		-- colors = {}, -- table of hex strings
		-- termcolors = {} -- table of colour name strings
	},
})

require("lsp_lines").setup()
require("gitlinker").setup()

lvim.lsp.diagnostics.virtual_text = false
require("telescope").load_extension("fzf")
require("telescope").load_extension("harpoon")
lvim.builtin.telescope.pickers.live_grep = {
	layout_strategy = "horizontal",
	layout_config = {
		width = 0.9,
		height = 0.9,
		prompt_position = "top",
	},
}

lvim.builtin.telescope.pickers.grep_string = {
	layout_strategy = "horizontal",
	layout_config = {
		width = 0.9,
		height = 0.9,
		prompt_position = "top",
	},
}

vim.api.nvim_create_autocmd({ "BufNew", "BufRead" }, {
	pattern = { "*.astro" },
	command = "setf astro",
})

-- Thank you to ThePrimeagen
-- make timeout on yank faster
vim.api.nvim_create_autocmd({ "TextYankPost" }, {
	pattern = { "*" },
	callback = function()
		vim.highlight.on_yank({
			higroup = "IncSearch",
			timeout = 40,
		})
	end,
})

require("lab").setup({
	code_runner = {
		enabled = true,
	},
	quick_data = {
		enabled = true,
	},
})
lvim.builtin.treesitter.textobjects = {
	select = {
		enable = true,
		keymaps = {
			-- You can use the capture groups defined in textobjects.scm
			["af"] = "@function.outer",
			["if"] = "@function.inner",
			["ac"] = "@class.outer",
			["ic"] = "@class.inner",
			["ab"] = "@block.outer",
			["ib"] = "@block.inner",
			-- ["ax"] = "@table.outer",
		},
	},
}
