local lvim = lvim
require("telescope").load_extension("fzf")
require("telescope").load_extension("harpoon")

lvim.builtin.which_key.mappings["s"]["w"] = {
	"<cmd>Telescope grep_string<CR>",
	"Current Word",
}

lvim.builtin.which_key.mappings["t"] = {
	"<cmd>Telescope colorscheme<CR>",
	"Color Scheme",
}

lvim.builtin.which_key.mappings["b"] = {
	"<cmd>Telescope buffers<CR>",
	"List Buffers",
}
lvim.builtin.telescope.pickers.live_grep = {
	layout_strategy = "horizontal",
	layout_config = {
		width = 0.9,
		height = 0.9,
		prompt_position = "top",
	},
}

lvim.builtin.telescope.pickers.grep_string = {
	layout_strategy = "horizontal",
	layout_config = {
		width = 0.9,
		height = 0.9,
		prompt_position = "top",
	},
}



