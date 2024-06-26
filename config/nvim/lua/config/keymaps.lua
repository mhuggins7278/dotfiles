-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set
local del = vim.keymap.del
-- remap esscape to jj in insert mode
map("i", "jj", "<Esc>", { silent = true })

--center cursor after various movement commands
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")
-- vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
-- vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")

map("n", "{", "{zz")
map("n", "}", "}zz")

--move line up and down
map("n", "J", "mzJ`z", { desc = "Join Line Below" })
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move Line Up" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move Line Down" })

--remap LazyVim window commands to W instead of w. I need <leader>w for saving
--
--delete the original keymaps
del("n", "<leader>ww")
del("n", "<leader>wd")
del("n", "<leader>w-")
del("n", "<leader>w|")
-- readd the maps but with W
map("n", "<leader>Ww", "<C-W>p", { desc = "Other window", remap = true })
map("n", "<leader>Wd", "<C-W>c", { desc = "Delete window", remap = true })
map("n", "<leader>W-", "<C-W>s", { desc = "Split window below", remap = true })
map("n", "<leader>W|", "<C-W>v", { desc = "Split window right", remap = true })

map("n", "<leader>w", ":w<CR>", { desc = "Save file", remap = true, silent = true })

map("n", "<leader>gg", ":!tmux new-window 'lazygit'<CR>", { desc = "Open lazygit", remap = true, silent = true })
