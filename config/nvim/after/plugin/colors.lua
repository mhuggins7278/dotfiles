require("rose-pine").setup({
	disable_background = true,
})
require("tokyonight").setup({
	transparent = true,
	styles = {
		floats = "transparent",
	},
})
require("catppuccin").setup({
	flavour = "mocha",
	term_colors = true,
	integrations = {
		octo = true,
		which_key = true,
		alpha = true,
		treesitter = true,
		harpoon = true,
		cmp = true,
		gitsigns = true,
		mason = true,
		noice = true,
		dap = {
			enabled = true,
			enable_ui = true,
		},
	},
})

require("kanagawa").setup({
	transparent = true,
})

function ColorMyPencils(color)
	color = color or "catppuccin"
	vim.cmd.colorscheme(color)
	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

-- vim.opt.termguicolors = true
ColorMyPencils()
