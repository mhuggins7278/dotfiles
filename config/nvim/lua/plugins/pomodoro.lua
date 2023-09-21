return {
    'wthollingsworth/pomodoro.nvim',
    dependencies = {'MunifTanjim/nui.nvim'},
    config = function()
        require('pomodoro').setup({
            time_work = 50,
            time_break_short = 10,
            time_break_long = 30,
            timers_to_long_break = 2
        })
    end
}
