lvim.plugins = {
	"nvim-treesitter/nvim-treesitter-textobjects",
	"nvim-telescope/telescope-ui-select.nvim",
	"ThePrimeagen/harpoon",
	-- "uga-rosa/ccc.nvim",
	"projekt0n/github-nvim-theme",
	"Mofiqul/dracula.nvim",
	"kdheepak/lazygit.nvim",
	"kchmck/vim-coffee-script",
	"ellisonleao/gruvbox.nvim",
	-- "ellisonleao/glow.nvim",
	"tpope/vim-surround",
	"p00f/nvim-ts-rainbow",
	"catppuccin/vim",
	-- "David-Kunz/jester",
	-- "tpope/vim-unimpaired",
	"nvim-telescope/telescope-file-browser.nvim",
	-- "ggandor/leap.nvim",
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
				require("copilot").setup({
					plugin_manager_path = os.getenv("LUNARVIM_RUNTIME_DIR") .. "/site/pack/packer",
					suggestions = {
						auto_trigger = true,
					},
				})
			end, 100)
		end,
	},
	{
		"zbirenbaum/copilot-cmp",
		after = { "copilot.lua" },
		config = function()
			require("copilot_cmp").setup({ method = "getCompletionsCycling" })
		end,
	},
	{
		"folke/zen-mode.nvim",

		config = function()
			require("zen-mode").setup()
		end,
	},
	-- {
	-- 	"folke/noice.nvim",
	-- 	requires = {
	-- 		"MunifTanjim/nui.nvim",
	-- 		"rcarriga/nvim-notify",
	-- 	},
	-- },
	-- {
	-- 	"folke/trouble.nvim",
	-- 	cmd = "TroubleToggle",
	-- },
}
