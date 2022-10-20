local create_autocmd = vim.api.nvim_create_autocmd

local commands = {
	{
		{ "BufNew", "BufRead" },
		{
			pattern = { "*.astro" },
			command = "setf astro",
		},
	},
	{
		{ "TextYankPost" },
		{
			pattern = { "*" },
			callback = function()
				vim.highlight.on_yank({
					higroup = "IncSearch",
					timeout = 40,
				})
			end,
		},
	},
	{
		{ "BufWritePost" },
		{
			pattern = { "plugins.lua" },
			callback = function()
				vim.cmd("PackerSync")
				vim.cmd("PackerCompile")
			end,
		},
	},
}

local autocmds = require "lvim.core.autocmds"



autocmds.define_autocmds(commands)

