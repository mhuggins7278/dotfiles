local vim = vim
local lvim = lvim
vim.g.copilot_no_tab_map = true
vim.g.copilot_assume_mapped = true
vim.g.copilot_tab_fallback = ""
vim.g.copilot_node_command = "/Users/MHuggins/.nvm/versions/node/v16.15.1/bin/node"

-- vim.api.nvim_set_keymap("i", "<C-f>", 'copilot#Accept("<CR>")', { silent = true, expr = true })

-- Can not be placed into the config method of the plugins.
table.insert(lvim.builtin.cmp.sources, 1, { name = "copilot", group_index = 2 })
lvim.builtin.cmp.formatting.source_names["copilot"] = "(Copilot)"
local cmp = require("cmp")
cmp.event:on("menu_opened", function()
	vim.b.copilot_suggestion_hidden = true
end)

cmp.event:on("menu_closed", function()
	vim.b.copilot_suggestion_hidden = false
end)
