return {
  {
    "pwntester/octo.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("octo").setup({
        use_local_fs = true,
        enable_builtin = true,
        -- mappings = {
        --   submit_win = {
        --     approve_review = { lhs = "<C-s>", desc = "approve review" },
        --     comment_review = { lhs = "<C-m>", desc = "comment review" },
        --     request_changes = { lhs = "<C-r>", desc = "request changes review" },
        --     close_review_tab = { lhs = "<C-c>", desc = "close review tab" },
        --   },
        -- },
      })
    end,
  },
  {
    vim.treesitter.language.register("markdown", "octo"),
  },
}
