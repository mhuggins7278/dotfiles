return {
	{
		"folke/zen-mode.nvim",
		event = "BufRead",
		opts = {
			window = {
				width = 120,
				options = {
					number = true,
					relativenumber = true,
				},
			},
		},
	},
	{

		vim.keymap.set("n", "<leader>z", function()
			require("zen-mode").toggle()
			vim.wo.wrap = false
			ColorMyPencils()
		end, { desc = "+ZenMode" }),
	},
}
