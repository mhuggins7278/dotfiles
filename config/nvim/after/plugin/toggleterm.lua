require 'toggleterm'.setup {
  shade_terminals = false,
  direction = 'float',
  shell = vim.o.shell,
  persist_mode = true
}
vim.keymap.set('n', '<C-\\>', '<cmd>ToggleTerm<cr>')
vim.keymap.set('t', '<C-\\>', '<cmd>ToggleTerm<cr>')
-- if you only want these mappings for toggle term use term://*toggleterm#* instead
-- vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
