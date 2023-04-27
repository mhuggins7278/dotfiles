return {
  "ahmedkhalf/project.nvim",
  config = function()
    require("project_nvim").setup({
       silent_chdir = true,
      ignore_lsp = {"null-ls"},
    })
  end,
}
