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
	transparent_background = true,
	term_colors = true,
	integrations = {
		alpha = true,
		cmp = true,
		dap = {
			enabled = true,
			enable_ui = true,
		},
		gitsigns = true,
		harpoon = true,
		lsp_trouble = true,
		markdown = true,
		mason = true,
		native_lsp = {
			enabled = true,
			virtual_text = {
				errors = { "italic" },
				hints = { "italic" },
				warnings = { "italic" },
				information = { "italic" },
			},
			underlines = {
				errors = { "undercurl" },
				hints = { "undercurl" },
				warnings = { "undercurl" },
				information = { "undercurl" },
			},
			inlay_hints = {
				background = true,
			},
		},
		noice = true,
		notify = true,
		nvimtree = true,
		octo = true,
		telescope = true,
		treesitter = true,
		treesitter_context = true,
		ts_rainbow2 = true,
		which_key = true,
	},
	styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
		comments = { "italic" }, -- Change the style of comments
		conditionals = { "italic" },
	},
	compile_path = vim.fn.stdpath("cache") .. "/catppuccin",
})

require("kanagawa").setup({
	transparent = true,
})

require("github-theme").setup({
	options = {
		compile_path = vim.fn.stdpath("cache") .. "/github-theme",
		compile_file_suffix = "_compiled", -- Compiled file suffix
		hide_end_of_buffer = true, -- Hide the '~' character at the end of the buffer for a cleaner look
		hide_nc_statusline = true, -- Override the underline style for non-active statuslines
		transparent = false, -- Disable setting background
		terminal_colors = true, -- Set terminal colors (vim.g.terminal_color_*) used in `:terminal`
		dim_inactive = false, -- Non focused panes set to alternative background
		module_default = true,
	},
	modules = { -- List of various plugins and additional options
		octo = true,
		which_key = true,
		lualine = true,
		alpha = true,
		treesitter = true,
		telescope = { enabled = true },
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

function ColorMyPencils(color)
	color = color or "catppuccin"
	vim.cmd.colorscheme(color)
	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

ColorMyPencils()
