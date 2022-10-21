-- lvim.lsp.diagnostics.virtual_text = false
-- -- set a formatter, this will override the language server formatting capabilities (if it exists)
local formatters = require("lvim.lsp.null-ls.formatters")
formatters.setup({
	{
		command = "prettierd",
		extra_args = { "--print-with", "100" },
		filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact", "astro" },
	},
	{ command = "stylua", filetypes = { "lua" } },
	{ command = "sql-formatter", filetypes = { "sql" } },
})

-- set additional linters
local linters = require("lvim.lsp.null-ls.linters")
linters.setup({
	{
		command = "eslint_d",
		filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	},
	{
		command = "luacheck",
		filetypes = { "lua" },
	},
})

require("lvim.lsp.manager").setup("astro")
require("lvim.lsp.manager").setup("emmet_ls")
