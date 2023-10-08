require("rose-pine").setup({
  disable_background = true,
})
require("tokyonight").setup({
  transparent = true,
  styles = {
    floats = "transparent",
  },
})
require("catppuccin").setup({
  flavour = "mocha",
  term_colors = false,
  transparent_background = false,
  integrations = {
    alpha = true,
    cmp = true,
    dap = {
      enabled = true,
      enable_ui = true,
    },
    gitsigns = true,
    harpoon = true,
    lsp_trouble = true,
    markdown = true,
    mason = true,
    native_lsp = {
      enabled = true,
      virtual_text = {
        errors = { "italic" },
        hints = { "italic" },
        warnings = { "italic" },
        information = { "italic" },
      },
      underlines = {
        errors = { "underline" },
        hints = { "underline" },
        warnings = { "underline" },
        information = { "underline" },
      },
      inlay_hints = {
        background = true,
      },
    },
    noice = true,
    notify = true,
    nvimtree = true,
    octo = true,
    telescope = {
      enabled = true,
    },
    treesitter = true,
    treesitter_context = true,
    ts_rainbow2 = true,
    which_key = true,
  },
  styles = {                 -- Handles the styles of general hi groups (see `:h highlight-args`):
    comments = { "italic" }, -- Change the style of comments
    conditionals = { "italic" },
  },
  compile_path = vim.fn.stdpath "cache" .. "/catppuccin"
})

require("kanagawa").setup({
  transparent = true,
})

require("github-theme").setup({
  options = {
    transparent = true,
  },
  modules = { -- List of various plugins and additional options
    octo = true,
    which_key = true,
    lualine = true,
    alpha = true,
    treesitter = true,
    telescope = true,
    harpoon = true,
    cmp = true,
    gitsigns = true,
    mason = true,
    noice = true,
    dap = {
      enabled = true,
      enable_ui = true,
    },
  },
})

function ColorMyPencils(color)
  color = color or "catppuccin"
  vim.cmd.colorscheme(color)
  vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

ColorMyPencils()
