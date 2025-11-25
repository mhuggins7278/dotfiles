return {
  'obsidian-nvim/obsidian.nvim',
  version = '*', -- recommended, use latest release instead of latest commit
  ft = 'markdown',
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  -- event = {
  --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
  --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
  --   -- refer to `:h file-pattern` for more examples
  --   "BufReadPre path/to/my-vault/*.md",
  --   "BufNewFile path/to/my-vault/*.md",
  -- },
  ---@module 'obsidian'
  ---@type obsidian.config
  opts = {
    workspaces = {
      {
        name = 'vault',
        path = '~/github/mhuggins7278/notes',
      },
    },
    daily_notes = {
      -- Optional, if you keep daily notes in a separate directory.
      folder = 'dailies',
    },
    legacy_commands = false,

    -- see below for full list of options 👇
  },
  keys = {
    {
      '<leader>nt',
      function()
        local tasknotes = require 'tasknotes'
        
        -- Prompt for task title
        vim.ui.input({ prompt = 'Task title: ' }, function(title)
          if not title or title == '' then
            vim.notify('Task creation cancelled', vim.log.levels.INFO)
            return
          end
          
          -- Prompt for task details
          vim.ui.input({ prompt = 'Task details (optional): ' }, function(details)
            -- Create the task with basic data
            local task_data = {
              title = title,
              status = 'todo',
              priority = 'normal',
            }
            
            -- Add details if provided
            if details and details ~= '' then
              task_data.details = details
            end
            
            local response = tasknotes.tasks.create(task_data)
            
            if response.success then
              vim.notify('Created task: ' .. title, vim.log.levels.INFO)
            else
              vim.notify('Error creating task: ' .. (response.error or 'Unknown error'), vim.log.levels.ERROR)
            end
          end)
        end)
      end,
      desc = 'Create new task',
    },
  },
}
