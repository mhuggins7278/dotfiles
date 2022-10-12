local lvim = lvim
local vim = vim
lvim.plugins = {
 "nvim-treesitter/nvim-treesitter-textobjects",
 "ThePrimeagen/harpoon",
 "uga-rosa/ccc.nvim",
 "j-hui/fidget.nvim",
 "projekt0n/github-nvim-theme",
 "Mofiqul/dracula.nvim",
 "kdheepak/lazygit.nvim",
 "kchmck/vim-coffee-script",
 "ellisonleao/gruvbox.nvim",
 "ellisonleao/glow.nvim",
 "tpope/vim-surround",
 "p00f/nvim-ts-rainbow",
 "catppuccin/vim",
 "David-Kunz/jester",
	{
		"https://git.sr.ht/~whynothugo/lsp_lines.nvim",
		config = function()
			require("lsp_lines").setup()
		end,
	},
	{ "ruifm/gitlinker.nvim", requires = "nvim-lua/plenary.nvim" },
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
	{
		"zbirenbaum/copilot.lua",
		event = { "VimEnter" },
		config = function()
			vim.defer_fn(function()
				require("copilot").setup{
					plugin_manager_path = "/Users/MHuggins/.local/share/lunarvim/site/pack/packer"
				}
			end, 100)
		end,
	},

	{
		"zbirenbaum/copilot-cmp",
		after = { "copilot.lua" },
		config = function()
			require("copilot_cmp").setup({
				method = "getCompletionCycling",
			})
		end,
	},
	{
		"folke/trouble.nvim",
		cmd = "TroubleToggle",
	},
}

