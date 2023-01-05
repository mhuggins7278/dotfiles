require 'telescope'.load_extension('project')
require("telescope").load_extension("ui-select")

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>sf', builtin.find_files, {})
vim.keymap.set('n', '<leader>sg', builtin.git_files, {})
vim.keymap.set('n', '<leader>sw', builtin.grep_string, {})
vim.keymap.set('n', '<leader>st', builtin.live_grep, {})
vim.keymap.set('n', '<leader>sp', ":lua require'telescope'.extensions.project.project{}<CR>")

require('telescope').setup {
  extensions = {
    project = {
      base_dirs = {
        { path = '~/github', max_depth = 2 },
      },
      hidden_files = true, -- default: false
      theme = "center",
      order_by = "asc",
      search_by = "title",
      sync_with_nvim_tree = true, -- default false
    },
    ["ui-select"] = {
      require("telescope.themes").get_cursor {
        -- even more opts
      }
    }
  }
}
