return {
		"folke/todo-comments.nvim",
		dependencies = "nvim-lua/plenary.nvim",
        event = "BufRead",
		config = function()
			require("todo-comments").setup({
				-- your configuration comes here
				-- or leave it empty to use the default settings
				-- refer to the configuration section below
			})
		end,
}
