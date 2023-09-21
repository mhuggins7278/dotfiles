return {
  "zbirenbaum/copilot-cmp",
  dependencies = {"zbirenbaum/copilot.lua"},
  event = "InsertEnter",
  config = true,
  init = function()
    require("copilot").setup({
      suggestion = {
        enabled = false
      },
      panel = {
        enabled = false
      }
    })
  end,
}
