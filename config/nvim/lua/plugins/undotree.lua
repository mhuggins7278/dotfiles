return {
    'mbbill/undotree',
        event = 'BufReadPre',
},
{
    vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Toggle UndotreeToggle" })
}
