-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
--
--

local function augroup(name)
  return vim.api.nvim_create_augroup("user_" .. name, { clear = true })
end

-- vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
--   group = augroup("snowflake"),
--   callback = function()
--     if vim.o.filetype == "snowflake" then
--       vim.cmd("set filetype=sql")
--     end
--   end,
-- })
vim.api.nvim_command(
  "autocmd BufNewFile,BufRead **/epiquery-templates/**/*.mustache,**/epiquery-templates/**/*.snowflake setfiletype sql"
)
