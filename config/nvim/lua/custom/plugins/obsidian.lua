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
    ui = {
      enable = false, -- completely disable all obsidian.nvim UI features
      checkboxes = {}, -- disable checkbox rendering
    },
    daily_notes = {
      -- Optional, if you keep daily notes in a separate directory.
      folder = 'dailies',
    },
    legacy_commands = false,

    -- see below for full list of options 👇
  },
}
