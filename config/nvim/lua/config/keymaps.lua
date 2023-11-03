-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- tmux navigation
vim.keymap.set("n", "<c-h>", ":<C-U>TmuxNavigateLeft<cr>", { silent = true })
vim.keymap.set("n", "<c-j>", ":<C-U>TmuxNavigateDown<cr>", { silent = true })
vim.keymap.set("n", "<c-k>", ":<C-U>TmuxNavigateUp<cr>", { silent = true })
vim.keymap.set("n", "<c-l>", ":<C-U>TmuxNavigateRight<cr>", { silent = true })
vim.keymap.set("n", "<c->", ":<C-U>TmuxNavigatePrevious<cr>", { silent = true })

-- remap esscape to jj in insert mode
vim.keymap.set("i", "jj", "<Esc>", { silent = true })

--center cursor after various movement commands
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")

vim.keymap.set("n", "{", "{zz")
vim.keymap.set("n", "}", "}zz")

--move line up and down
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move Line Up" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move Line Down" })
