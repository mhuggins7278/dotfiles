local opt = vim.opt

opt.foldexpr = "nvim_treesitter#foldexpr()"

lvim.builtin.treesitter.ensure_installed = {
	"bash",
	"c",
	"javascript",
	"json",
	"lua",
	"python",
	"typescript",
	"tsx",
	"css",
	"rust",
	"java",
	"yaml",
	"html",
	"svelte",
	"go",
}

lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enabled = true

lvim.builtin.treesitter.autotag.enable = true

require("nvim-treesitter.configs").setup({
	highlight = {
		-- ...
	},
	-- ...
	rainbow = {
		enable = true,
		-- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
		extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
		max_file_lines = nil, -- Do not enable for files with more than n lines, int
		-- colors = {}, -- table of hex strings
		-- termcolors = {} -- table of colour name strings
	},
})

lvim.builtin.treesitter.textobjects = {
	select = {
		enable = true,
		keymaps = {
			-- You can use the capture groups defined in textobjects.scm
			["af"] = "@function.outer",
			["if"] = "@function.inner",
			["ac"] = "@class.outer",
			["ic"] = "@class.inner",
			["ab"] = "@block.outer",
			["ib"] = "@block.inner",
			["ip"] = "@parameter.inner",
			["ap"] = "@parameter.outer",
			-- ["ax"] = "@table.outer",
		},
	},
}
