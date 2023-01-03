-- lvim.lsp.diagnostics.virtual_text = false
-- -- set a formatter, this will override the language server formatting capabilities (if it exists)

local formatters = require("lvim.lsp.null-ls.formatters")
local cmp = require("cmp")
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
require("lvim.lsp.manager").setup("deno")

local has_words_before = function()
  if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_text(0, line-1, 0, line-1, col, {})[1]:match("^%s*$") == nil
end
cmp.setup({
  mapping = {
    ["<Tab>"] = vim.schedule_wrap(function(fallback)
      if cmp.visible() and has_words_before() then
        cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
      else
        fallback()
      end
    end),
  },
})

