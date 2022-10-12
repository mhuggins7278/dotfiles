
local silent = { silent = true }

vim.api.nvim_set_keymap("n", "<C-d>", "<C-d>zz", silent)
vim.api.nvim_set_keymap("n", "<C-u>", "<C-u>zz", silent)
--paste in visual mode without overwriting register
vim.api.nvim_set_keymap("v", "<leader>r", '"_dP', silent)
--delete without overwriting register
vim.api.nvim_set_keymap("n", "<leader>d", '"_d', silent)
vim.api.nvim_set_keymap("v", "<leader>d", '"_d', silent)
vim.api.nvim_set_keymap("i", "jj", "<ESC>", silent)
vim.api.nvim_set_keymap("n", "gp", "<cmd>lua vim.lsp.buf.hover()<CR>", silent)

--harpoon key maps
vim.api.nvim_set_keymap("n", "<C-h>", '<cmd>lua require("harpoon.mark").add_file()<CR>', silent)
vim.api.nvim_set_keymap("n", "<C-j>", '<cmd>lua require("harpoon.ui").nav_file(1)<CR>', silent)
vim.api.nvim_set_keymap("n", "<C-k>", '<cmd>lua require("harpoon.ui").nav_file(2)<CR>', silent)
vim.api.nvim_set_keymap("n", "<C-l>", '<cmd>lua require("harpoon.ui").nav_file(3)<CR>', silent)
vim.api.nvim_set_keymap("n", "<C-;>", '<cmd>lua require("harpoon.ui").nav_file(4)<CR>', silent)
vim.api.nvim_set_keymap("n", "<C-n>", '<cmd>lua require("harpoon.ui").toggle_quick_menu()<CR>', silent)
