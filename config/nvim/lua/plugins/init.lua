-- This "file can be loaded by calling `lua require('plugins')` from your init.vim
return {

	{
		"rose-pine/neovim",
		as = "rose-pine",
	},

	-- Lua
	{
		"folke/which-key.nvim",
		config = function()
			require("which-key").setup({
				-- your configuration comes here
				-- or leave it empty to use the default settings
				-- refer to the configuration section below
			})
		end,
	},
  {
  "ellisonleao/glow.nvim",
  config = function()
    require("glow").setup({})
  end,
},
	"kchmck/vim-coffee-script",
	"ahmedkhalf/project.nvim",
	"folke/tokyonight.nvim",
	"tpope/vim-surround",
	"nvim-tree/nvim-web-devicons",
	"mfussenegger/nvim-dap",
	"jayp0521/mason-nvim-dap.nvim",
	{ "catppuccin/nvim", as = "catppuccin" },
	"rebelot/kanagawa.nvim",
	"jose-elias-alvarez/null-ls.nvim",
	"jay-babu/mason-null-ls.nvim",
}
