-----------------------------------------------------------
-- Autocommand functions
-----------------------------------------------------------

-- Define autocommands with Lua APIs
-- See: h:api-autocmd, h:augroup

local augroup = vim.api.nvim_create_augroup   -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd   -- Create autocommand

augroup('Folding', {clear = true})
autocmd({"BufReadPost", "FileReadPost", "BufWinEnter"},{
  group = "Folding",
  command = "normal zR"
})
