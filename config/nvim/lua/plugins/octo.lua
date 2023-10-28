return {
	{
		"pwntester/octo.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("octo").setup({
				mappings = {
					submit_win = {
						approve_review = { lhs = "<C-s>", desc = "approve review" },
						comment_review = { lhs = "<C-m>", desc = "comment review" },
						request_changes = { lhs = "<C-r>", desc = "request changes review" },
						close_review_tab = { lhs = "<C-c>", desc = "close review tab" },
					},
				},
			})
		end,
		init = function()
			local wk = require("which-key")
			wk.register({
				["o"] = {
					name = "+octo",
					["i"] = {
						":Octo search repo:glg/Client-Solutions-Experience is:issue is:open<CR>",
						"Search Issues",
					},
					["p"] = { ":Octo pr list<CR>", "List PRs" },
				},
			}, { prefix = "<leader>" })
		end,
	},
	{
		vim.treesitter.language.register("markdown", "octo"),
	},
}
