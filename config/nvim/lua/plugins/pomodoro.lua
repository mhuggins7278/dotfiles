return {
    'wthollingsworth/pomodoro.nvim',
    dependencies = {'MunifTanjim/nui.nvim'},
    config = function()
        require('pomodoro').setup({
            time_work = 30,
            time_break_short = 5,
            time_break_long = 20,
            timers_to_long_break = 4
        })
    end
}
