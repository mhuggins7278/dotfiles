return {
  "weilbith/nvim-code-action-menu",
  cmd = "CodeActionMenu",
  event = "LspAttach",
  init = function ()
    local wk = require("which-key")
    wk.register({
      ["<leader>la"] = { "<cmd>CodeActionMenu<cr>", "Code Action Menu" },
    })
  end
}
