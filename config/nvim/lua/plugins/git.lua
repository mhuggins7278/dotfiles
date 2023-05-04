return {
    {
        'lewis6991/gitsigns.nvim',
        event = 'BufRead',
        config = function()
            require('gitsigns').setup({
              numhl = true,
              linehl = false
            })
        end
    },
    {
    function()
      local wk = require('which-key')
    wk.register({
      ["g"] = {
          name = "+git",
        s = {':Gitsigns stage_hunk<CR>', 'Stage hunk' },
        r = {':Gitsigns reset_hunk<CR>', 'Reset hunk' },
        S = {':Gitsigns stage_buffer<CR>', 'Stage buffer' },
        u = {':Gitsigns undo_stage_hunk<CR>', 'Undo stage hunk' },
        R = {':Gitsigns reset_buffer<CR>', 'Reset buffer' },
        P = {':Gitsigns preview_hunk<CR>', 'Preview hunk' },
        B = {':Gitsigns blame_line<CR>', 'Blame line' },
        b = {':Gitsigns toggle_current_line_blame<CR>', 'Toggle blame' },
        d = {':Gitsigns diffthis<CR>', 'Diff this' },
        D = {':Gitsigns diffthis<CR>', 'Diff this against HEAD' },
        x = {':Gitsigns toggle_deleted<CR>', 'Toggle deleted' },
        p = {':Gitsigns prev_hunk<CR>', 'Prev Hunk' },
        n = {':Gitsigns next_hunk<CR>', 'Next Hunk' },
    }, { prefix = "<leader>" })

    end
    }
}
