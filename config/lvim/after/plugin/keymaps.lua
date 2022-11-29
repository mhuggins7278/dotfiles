local silent = { silent = true }
local map = vim.api.nvim_set_keymap

map("n", "<C-d>", "<C-d>zz", silent)
map("n", "<C-u>", "<C-u>zz", silent)
--paste in visual mode without overwriting register
map("v", "<leader>r", '"_dP', silent)
--delete without overwriting register
map("n", "<leader>d", '"_d', silent)
map("v", "<leader>d", '"_d', silent)
map("i", "jj", "<ESC>", silent)
map("n", "gp", "<cmd>lua vim.lsp.buf.hover()<CR>", silent)

--harpoon key maps
map("n", "<C-h>", '<cmd>lua require("harpoon.mark").add_file()<CR>', silent)
map("n", "<C-j>", '<cmd>lua require("harpoon.ui").nav_file(1)<CR>', silent)
map("n", "<C-k>", '<cmd>lua require("harpoon.ui").nav_file(2)<CR>', silent)
map("n", "<C-l>", '<cmd>lua require("harpoon.ui").nav_file(3)<CR>', silent)
map("n", "<C-;>", '<cmd>lua require("harpoon.ui").nav_file(4)<CR>', silent)
map("n", "<C-n>", '<cmd>lua require("harpoon.ui").toggle_quick_menu()<CR>', silent)
--zen mode toggle
map("n", "<C-z>", '<cmd>ZenMode<CR>', silent)


-- When going through search results, center the tab/window/buffer/thing.
map('n', 'n', 'nzzzv', silent)
-- Do the same thing as above, but for backwards.
map('n', 'N', 'Nzzzv', silent)

--move the selected block up/down one line
map('v', 'J', ":m '>+1<CR>gv=gv", silent)
map('v', 'K', ":m '<-2<CR>gv=gv", silent)
