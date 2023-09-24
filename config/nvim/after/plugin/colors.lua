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
  term_colors = true,
  transparent_background = false,
  integrations = {
    octo = true,
    which_key = true,
    alpha = true,
    treesitter = true,
    harpoon = true,
    cmp = true,
    gitsigns = true,
    mason = true,
    noice = true,
    notify = true,
    nvimtree = true,
    markdown = true,
    telescope = {
      enabled = true,
    },
    dap = {
      enabled = true,
      enable_ui = true,
    },
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
