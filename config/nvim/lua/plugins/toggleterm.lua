return {
    {

        'akinsho/toggleterm.nvim',
        event = 'BufRead',
        config = function()
            require('toggleterm').setup {
                open_mapping = [[<c-\>]],
                hide_numbers = true,
                shade_terminals = false,
                start_in_insert = true,
                insert_mappings = true,
                persist_size = true,
                persist_mode = true,
                direction = 'float',
                close_on_exit = true,
                shell = vim.o.shell,
            }
        end,
    },
    {
        { vim.keymap.set('n', '<C-\\>', '<cmd>ToggleTerm<cr>') },
        { vim.keymap.set('t', '<C-\\>', '<cmd>ToggleTerm<cr>') },
    }
}
-- if you only want these mappings for toggle term use term://*toggleterm#* instead
-- vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
