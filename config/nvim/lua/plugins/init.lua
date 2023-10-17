-- This "file can be loaded by calling `lua require('plugins')` from your init.vim
return {

	{
		"rose-pine/neovim",
		as = "rose-pine",
	},

	-- Lua
	"kchmck/vim-coffee-script",
	"folke/tokyonight.nvim",
  "projekt0n/github-nvim-theme",
	"tpope/vim-surround",
  "mustache/vim-mustache-handlebars",
  "digitaltoad/vim-pug",
	"nvim-tree/nvim-web-devicons",
	"mfussenegger/nvim-dap",
	{ "catppuccin/nvim", as = "catppuccin" },
	"rebelot/kanagawa.nvim",
	"jose-elias-alvarez/null-ls.nvim",
	-- "jay-babu/mason-null-ls.nvim",
	"nikvdp/ejs-syntax",
	{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	"nvim-telescope/telescope-file-browser.nvim",
	"nvim-telescope/telescope-ui-select.nvim",
	"nvim-telescope/telescope-live-grep-args.nvim",
	"nvim-treesitter/playground",
	"nvim-treesitter/nvim-treesitter-textobjects",
	"nvim-treesitter/nvim-treesitter-context",
	"tpope/vim-abolish",
	"tpope/vim-fugitive",
	"tpope/vim-repeat",
	"christoomey/vim-tmux-navigator",
	{
		"danymat/neogen",
		dependencies = "nvim-treesitter/nvim-treesitter",
		config = true,
	},
}
