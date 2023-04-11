vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "Open NetRW" })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move Line Up" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "<leader>w", ":w<CR>")
vim.keymap.set("n", "<leader>q", ":q<CR>")

-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]])

-- next greatest remap ever : asbjornHaland
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set({ "n", "v" }, "<leader>D", [["_d]])

vim.keymap.set("i", "jj", "<Esc>", {silent = true})

vim.keymap.set("n", "Q", "<nop>")

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")

vim.keymap.set("n", "<leader>r", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "chmod +x" })
vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<CR>")

vim.keymap.set("n", "<leader>c", "<cmd>bd<CR>", { desc = "close buffer" })
vim.keymap.set("n", "<leader>ls", vim.lsp.buf.workspace_symbol, { desc = "Symbols" })
vim.keymap.set("n", "<leader>ld", vim.diagnostic.open_float, { desc = "Diagnostics" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_next, { remap = false, desc = "Next Diag" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, { remap = false, desc = "Prev Diag" })

vim.keymap.set("n", "<leader>lnf", ":Neogen func<CR>", {remap = false, desc = "Doc Function"})
vim.keymap.set("n", "<leader>lnc", ":Neogen class<CR>", {remap = false, desc = "Doc Class"})
vim.keymap.set("n", "<leader>lnt", ":Neogen type<CR>", {remap = false, desc = "Doc Type"})

