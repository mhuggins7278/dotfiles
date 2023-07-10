return {
  "kosayoda/nvim-lightbulb",
  config = function()
    require("nvim-lightbulb").setup({
      autocmd = { enabled = true },
      ignore = {
        -- LSP client names to ignore.
        -- Example: {"null-ls", "lua_ls"}
        clients = {},
      },
    })
  end,
}
