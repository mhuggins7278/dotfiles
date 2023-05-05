return {
  "ahmedkhalf/project.nvim",
  config = function()
    require("project_nvim").setup({
      silent_chdir = true,
      ignore_lsp = { "null-ls", "tsserver" },
      detection_methods = { "pattern", "lsp" },
    })
  end,
}
