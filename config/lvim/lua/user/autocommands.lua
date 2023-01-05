-- vim.api.nvim_create_autocmd({ "BufNew", "BufRead" }, {
-- 	pattern = { "*.astro" },
-- 	command = "setf astro",
-- })

-- Thank you to ThePrimeagen
-- make timeout on yank faster
vim.api.nvim_create_autocmd({ "TextYankPost" }, {
	pattern = { "*" },
	callback = function()
		vim.highlight.on_yank({
			higroup = "IncSearch",
			timeout = 40,
		})
	end,
})

vim.api.nvim_create_autocmd({"BufWritePost"}, {
pattern = {"plugins.lua"},
callback = function()
    vim.cmd("so")
    vim.cmd("PackerSync")
    vim.cmd("PackerCompile")
  end
})

