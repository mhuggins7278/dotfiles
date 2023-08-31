return {
	{
		"nvim-tree/nvim-tree.lua",
		config = function()
			require("nvim-tree").setup({
				-- disable_netrw = false,
        hijack_netrw = false,
				sync_root_with_cwd = true,
				respect_buf_cwd = true,
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
			})
		end,
	},
	{
		vim.keymap.set("n", "<C-n>", "<cmd>NvimTreeToggle<CR>"),
	},
}
