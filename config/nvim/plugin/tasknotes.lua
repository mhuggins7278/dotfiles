-- Register TaskNotes commands with obsidian.nvim
-- This file integrates TaskNotes HTTP API with obsidian.nvim

-- Check if obsidian.nvim is loaded
local ok, obsidian = pcall(require, 'obsidian')
if not ok then
  return
end

-- Initialize tasknotes with default config
-- Users can override in their obsidian.nvim config
require('tasknotes').setup {
  api_url = 'http://localhost:8080',
  auth_token = nil, -- Set this if your TaskNotes API requires authentication
}

-- Register commands with obsidian.nvim
-- These will be available as :Obsidian <command_name>

-- List and select tasks with Telescope (or vim.ui.select fallback)
obsidian.register_command('tasknotes', { nargs = 0 })

-- Toggle time tracking for current task file
obsidian.register_command('timetrack', { nargs = 0 })

-- Show active time tracking sessions
obsidian.register_command('timesummary', { nargs = 0 })

-- Start a Pomodoro session for current task
obsidian.register_command('pomodoro', { nargs = 0 })
