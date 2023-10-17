return {
  "mxsdev/nvim-dap-vscode-js",
  dependencies = { "mfussenegger/nvim-dap" },
  event = "BufRead",
  config = function()
    local dap = require("dap")
    require('dap-vscode-js').setup({
      debugger_path = vim.fn.stdpath('data') .. '/mason/packages/js-debug-adapter/js-debug/src/',
      adapters = { 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'pwa-extensionHost' },
    })
    for _, language in ipairs({ 'typescript', 'javascript' }) do
      dap.configurations[language] = {
        {
          name = 'Launch',
          type = 'pwa-node',
          request = 'launch',
          program = '${file}',
          rootPath = '${workspaceFolder}',
          cwd = '${workspaceFolder}',
          sourceMaps = true,
          skipFiles = { '<node_internals>/**' },
          protocol = 'inspector',
          console = 'integratedTerminal',
        },
        {
          name = 'Attach to node process',
          type = 'pwa-node',
          request = 'attach',
          rootPath = '${workspaceFolder}',
          processId = require('dap.utils').pick_process,
        },
      }
    end
  end
}
