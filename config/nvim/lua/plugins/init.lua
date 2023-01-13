-- This "file can be loaded by calling `lua require('plugins')` from your init.vim
return {

    {
        'rose-pine/neovim',
        as = 'rose-pine',
    },

    'theprimeagen/harpoon',
    'mbbill/undotree',

    -- Lua
    {
        'folke/which-key.nvim',
        config = function()
            require('which-key').setup {
                -- your configuration comes here
                -- or leave it empty to use the default settings
                -- refer to the configuration section below
            }
        end
    },
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons', opt = true }
    },
    {
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup()
        end
    },
	{
		"folke/todo-comments.nvim",
		dependencies = "nvim-lua/plenary.nvim",
		config = function()
			require("todo-comments").setup({
				-- your configuration comes here
				-- or leave it empty to use the default settings
				-- refer to the configuration section below
			})
		end,
	},
    { "rcarriga/nvim-dap-ui", dependencies = { "mfussenegger/nvim-dap" } },
    'folke/zen-mode.nvim',
    'github/copilot.vim',
    'kchmck/vim-coffee-script',
    'ahmedkhalf/project.nvim',
    'nvim-telescope/telescope-file-browser.nvim',
    'nvim-telescope/telescope-ui-select.nvim',
    'akinsho/toggleterm.nvim',
    'kdheepak/lazygit.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    'folke/tokyonight.nvim',
    'tpope/vim-surround',
    'nvim-tree/nvim-web-devicons',
    'mfussenegger/nvim-dap',
    'jayp0521/mason-nvim-dap.nvim',
    'lewis6991/gitsigns.nvim',
    {"catppuccin/nvim", as = "catppuccin"},
    'rebelot/kanagawa.nvim',

}
