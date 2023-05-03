return {
  {
  "pwntester/octo.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  config = {
    mappings = {
      submit_win = {
      approve_review = { lhs = "<C-s>", desc = "approve review" },
      }
    }
  }
},
  {
    vim.treesitter.language.register('markdown', 'octo')
  },
}
