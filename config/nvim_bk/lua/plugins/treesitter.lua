return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    -- add tsx and treesitter
    vim.list_extend(opts.ensure_installed, {
      "astro",
      "http",
      "markdown",
      "markdown_inline",
    })
  end,
}
