return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    actions.select_default:replace(function()
      actions.select_default()
      actions.center()
    end)
    require("telescope").setup({
      extensions = {
        ["ui-select"] = {
          require("telescope.themes").get_dropdown({}),
        },
        ["file_browser"] = {
          hijack_netrw = true,
        },
      },
    })
    require("telescope").load_extension("fzf")
    require("telescope").load_extension("ui-select")
    require("telescope").load_extension("file_browser")
    require("telescope").load_extension("live_grep_args")
    require("telescope").load_extension("notify")
    require("telescope").load_extension("refactoring")
    vim.keymap.set({ "n", "x" }, "<leader>rr", function()
      require("telescope").extensions.refactoring.refactors()
    end)

    local wk = require("which-key")
    wk.register({
      ["s"] = {
        name = "+search",
        ["f"] = {
          "<cmd>Telescope find_files find_command=rg,--hidden,--files,-g=!.git/ <cr>",
          "Find All Files",
        },
        ["F"] = { "<cmd>Telescope file_browser<cr>", "File Browser" },
        ["g"] = { "<cmd>Telescope git_files<cr>", "Find Git Files" },
        ["w"] = { "<cmd>Telescope grep_string<cr>", "Find Current Word" },
        ["b"] = { "<cmd>Telescope buffers<cr>", "Find Buffers" },
        ["r"] = { "<cmd>Telescope oldfiles<cr>", "Find Recent Files" },
        ["h"] = { "<cmd>Telescope help_tags<cr>", "Help" },
        ["T"] = { "<cmd>TodoTelescope<cr>", "Find Todos" },
        ["R"] = { "<cmd>Telescope resume<cr>", "Reopen" },
        ["t"] = {
          ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>",
          "Find Text",
        },
        ["p"] = {
          ":lua require'telescope'.extensions.projects.projects()<CR>",
          "Find Project",
        },
        ["a"] = {
          ":lua require('nx.actions').actions_finder({opts})<CR>",
          "NX actions",
        },
      },
      ["r"] = {
        name = "+refactors",
        ["r"] = {
          ":lua require('telescope').extensions.refactoring.refactors()<CR>",
          "Refactors picker",
        },
      },
    }, { mode = { "n", "v", "x" }, prefix = "<leader>" })
  end,
}
