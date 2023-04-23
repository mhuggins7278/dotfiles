return {
	{
		"nvim-tree/nvim-tree.lua",
		config = {
			sync_root_with_cwd = true,
			update_focused_file = {
				enable = true,
				update_root = true,
			},
			view = {
				float = {
					enable = true,
					open_win_config = {
						width = 60,
						border = "rounded",
					},
				},
			},
		},
	},
	{
		vim.keymap.set("n", "<C-n>", "<cmd>NvimTreeToggle<CR>"),
	},
}
