return {
  -- it is critical to have the 'run' key provided because this
  -- plugin is a combination of lua and rust,
  -- with out this parameter the plugin will miss the compilation step entirely
  'napisani/nvim-github-codesearch',
  build = 'make',
  config = function()
    gh_search = require("nvim-github-codesearch")
    gh_search.setup({
      use_telescope = true
    })
  end,
}
