return {
  {
	"nvim-tree/nvim-tree.lua",
	config = {
		view = {
			float = {
				enable = true,
			},
		},
	},
},
	{
		vim.keymap.set("n", "<C-n>", "<cmd>NvimTreeToggle<CR>"),
	},
}
