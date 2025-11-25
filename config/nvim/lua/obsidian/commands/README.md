# obsidian.nvim TaskNotes Extension

This extension integrates [TaskNotes](https://github.com/callumalpass/tasknotes) HTTP API with [obsidian.nvim](https://github.com/obsidian-nvim/obsidian.nvim), allowing you to manage tasks, track time, and run Pomodoro sessions directly from Neovim.

## Features

- List and select tasks with Snacks or Telescope picker (with vim.ui.select fallback)
- Toggle time tracking for current task file
- View active time tracking sessions
- Start Pomodoro sessions for tasks
- Full HTTP API integration with TaskNotes

## Prerequisites

1. [TaskNotes Obsidian plugin](https://github.com/callumalpass/tasknotes) installed
2. TaskNotes HTTP API enabled in Obsidian settings (Desktop only)
3. [obsidian.nvim](https://github.com/obsidian-nvim/obsidian.nvim) configured
4. (Optional) [snacks.nvim](https://github.com/folke/snacks.nvim) for modern picker UI
5. (Optional) [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) for fuzzy finding

## Installation

This extension is built into your dotfiles. The files are already in place:

```
config/nvim/
├── lua/
│   ├── tasknotes/
│   │   └── init.lua              # TaskNotes API client
│   └── obsidian/
│       └── commands/
│           ├── tasknotes.lua     # Task picker command
│           ├── timetrack.lua     # Time tracking toggle
│           ├── timesummary.lua   # Active sessions viewer
│           └── pomodoro.lua      # Pomodoro starter
└── plugin/
    └── tasknotes.lua             # Command registration
```

## Configuration

### Enable TaskNotes API

1. Open Obsidian
2. Go to Settings → TaskNotes → HTTP API (desktop only)
3. Enable the API and set port (default: 8080)
4. (Optional) Set an authentication token
5. Restart Obsidian

### Configure the Extension

The extension uses default settings, but you can override them in your `plugin/tasknotes.lua`:

```lua
require('tasknotes').setup {
  api_url = 'http://localhost:8080',  -- TaskNotes API URL
  auth_token = nil,                    -- Set if API requires auth
}
```

## Available Commands

Once configured, you can use these commands in Neovim:

### `:Obsidian tasknotes`
Opens a picker showing all active tasks from TaskNotes. Select a task to open its file.

- Uses Snacks picker if available (modern, fast UI)
- Falls back to Telescope if Snacks not available (with fuzzy search)
- Falls back to `vim.ui.select` if neither available
- Shows task priority, status, title, and due date

### `:Obsidian timetrack`
Toggle time tracking for the current task file.

- If not tracking: Prompts for optional description and starts tracking
- If already tracking: Stops the timer
- Only works when editing a file in your Obsidian vault

### `:Obsidian timesummary`
Shows all currently active time tracking sessions in a floating window.

- Displays task title, elapsed time, description
- Shows associated projects
- Press `q` or `<Esc>` to close

### `:Obsidian pomodoro`
Starts a Pomodoro session for the current task file.

- Uses TaskNotes Pomodoro timer settings
- Notifies when session starts
- Only works when editing a file in your Obsidian vault

## Usage Examples

```vim
" Browse and open a task
:Obsidian tasknotes

" Start tracking time on current task
:Obsidian timetrack
" (Enter optional description when prompted)

" Check what you're currently tracking
:Obsidian timesummary

" Start a Pomodoro for focus work
:Obsidian pomodoro

" Stop tracking (run timetrack again while active)
:Obsidian timetrack
```

## Key Bindings (Optional)

Add these to your obsidian.nvim config for quick access:

```lua
{
  'obsidian-nvim/obsidian.nvim',
  keys = {
    { '<leader>ot', '<cmd>Obsidian tasknotes<cr>', desc = 'TaskNotes: Browse tasks' },
    { '<leader>oT', '<cmd>Obsidian timetrack<cr>', desc = 'TaskNotes: Toggle time tracking' },
    { '<leader>os', '<cmd>Obsidian timesummary<cr>', desc = 'TaskNotes: Active sessions' },
    { '<leader>op', '<cmd>Obsidian pomodoro<cr>', desc = 'TaskNotes: Start Pomodoro' },
  },
}
```

## API Client

The `tasknotes` module provides full access to the TaskNotes HTTP API:

```lua
local tasknotes = require('tasknotes')

-- Get all tasks (basic list)
local response = tasknotes.tasks.list()

-- Query tasks with filters (uses POST /api/tasks/query)
local response = tasknotes.tasks.list({ completed = false, archived = false })

-- Advanced query
local response = tasknotes.tasks.query({
  status = 'open',
  priority = 'High',
  overdue = true
})

-- Start time tracking with description
tasknotes.time.start('path/to/task.md', 'Working on feature X')

-- Get active sessions
local active = tasknotes.time.active_sessions()

-- Get time summary for today
local summary = tasknotes.time.summary('today')

-- Start a Pomodoro
tasknotes.pomodoro.start('path/to/task.md')

-- Get Pomodoro status
local status = tasknotes.pomodoro.status()
```

See `lua/tasknotes/init.lua` for the complete API reference.

## Troubleshooting

### Commands not available
- Make sure obsidian.nvim is loaded (`require('obsidian')` should work)
- Check that `plugin/tasknotes.lua` is being loaded
- Restart Neovim

### API connection errors
- Verify TaskNotes HTTP API is enabled in Obsidian
- Check the API is running: `curl http://localhost:8080/api/health`
- Ensure port matches your configuration
- Verify auth token if you set one

### Time tracking not working
- Make sure you're editing a file inside your Obsidian vault
- The file path must be relative to the vault root
- Check TaskNotes logs in Obsidian developer console

## Extension Structure

Following the [obsidian.nvim extension guidelines](https://github.com/obsidian-nvim/obsidian.nvim/wiki/Extensions):

```
lua/
├── tasknotes/init.lua         # Main API client module
└── obsidian/commands/         # Command implementations
    ├── tasknotes.lua          # Minimal command file (calls tasknotes module)
    ├── timetrack.lua
    ├── timesummary.lua
    └── pomodoro.lua
plugin/tasknotes.lua           # Registers commands with obsidian.nvim
```

Each command file is minimal and delegates to the `tasknotes` module for actual logic.

## License

Same as parent dotfiles repository (LICENSE file in repo root).

## References

- [TaskNotes Plugin](https://github.com/callumalpass/tasknotes)
- [TaskNotes HTTP API Docs](https://github.com/callumalpass/tasknotes/blob/main/docs/HTTP_API.md)
- [obsidian.nvim](https://github.com/obsidian-nvim/obsidian.nvim)
- [obsidian.nvim Extensions Guide](https://github.com/obsidian-nvim/obsidian.nvim/wiki/Extensions)
