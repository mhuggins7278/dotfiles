local vim = vim
vim.api.nvim_create_autocmd({ "BufNew", "BufRead" }, {
	pattern = { "*.astro" },
	command = "setf astro",
})

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

