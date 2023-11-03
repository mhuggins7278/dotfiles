return {
  "rcarriga/nvim-dap-ui",
  dependencies = { "mfussenegger/nvim-dap", "mxsdev/nvim-dap-vscode-js", "jay-babu/mason-nvim-dap.nvim" },
  event = "BufRead",
  config = function()
    require("dapui").setup()
    require("mason-nvim-dap").setup({
      ensure_installed = { 'js' },
      handlers = {}
    })
    local wk = require("which-key")
    wk.register({
      ["d"] = {
        name = "+debug",
        ["b"] = { "<cmd>lua require'dap'.toggle_breakpoint()<cr>", "Toggle Breakpoint" },
        ["sb"] = { "<cmd>lua require'dap'.step_back()<cr>", "Step Back" },
        ["sc"] = { "<cmd>lua require'dap'.continue()<cr>", "Continue" },
        ["so"] = { "<cmd>lua require'dap'.step_over()<cr>", "Step Over" },
        ["si"] = { "<cmd>lua require'dap'.step_into()<cr>", "Step Into" },
        ["su"] = { "<cmd>lua require'dap'.step_out()<cr>", "Step Out" },
        ["r"] = { "<cmd>lua require'dap'.run_to_cursor()<cr>", "Run To Cursor" },
        ["d"] = { "<cmd>lua require'dap'.disconnect()<cr>", "Disconnect" },
        ["g"] = { "<cmd>lua require'dap'.session()<cr>", "Get Session" },
        ["p"] = { "<cmd>lua require'dap'.pause()<cr>", "Pause" },
        ["R"] = { "<cmd>lua require'dap'.repl.toggle()<cr>", "Toggle Repl" },
        ["q"] = { "<cmd>lua require'dap'.close()<cr>", "Quit" },
        ["h"] = { ":lua require('dap.ui.widgets').hover()<CR>", "Show hover" },
        ["f"] = {
          ":lua local widgets=require('dap.ui.widgets');widgets.centered_float(widgets.scopes)<CR>",
          "Show scopes",
        },
        ["c"] = {
          "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
          "Set conditional breakpoint",
        },
        ["i"] = {
          "<cmd>lua require'dapui'.toggle({reset = true})<cr>",
          "Toggle UI",
        },
      },
    }, { prefix = "<leader>" })

    local sign = vim.fn.sign_define

    sign("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
    sign("DapBreakpointCondition", { text = "●", texthl = "DapBreakpointCondition", linehl = "", numhl = "" })
    sign("DapLogPoint", { text = "◆", texthl = "DapLogPoint", linehl = "", numhl = "" })
  end,
}
