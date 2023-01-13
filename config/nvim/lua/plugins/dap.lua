return {
    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "mfussenegger/nvim-dap" },
        event = 'BufReadPre',

        config = function()
            require("dapui").setup()
            vim.keymap.set('n', "<leader>Dt", "<cmd>lua require'dap'.toggle_breakpoint()<cr>",
                { desc = "Toggle Breakpoint" })
            vim.keymap.set('n', "<leader>Db", "<cmd>lua require'dap'.step_back()<cr>", { desc = "Step Back" })
            vim.keymap.set('n', "<leader>Dc", "<cmd>lua require'dap'.continue()<cr>", { desc = "Continue" })
            vim.keymap.set('n', "<leader>DC", "<cmd>lua require'dap'.run_to_cursor()<cr>", { desc = "Run To Cursor" })
            vim.keymap.set('n', "<leader>Dd", "<cmd>lua require'dap'.disconnect()<cr>", { desc = "Disconnect" })
            vim.keymap.set('n', "<leader>Dg", "<cmd>lua require'dap'.session()<cr>", { desc = "Get Session" })
            vim.keymap.set('n', "<leader>Di", "<cmd>lua require'dap'.step_into()<cr>", { desc = "Step Into" })
            vim.keymap.set('n', "<leader>Do", "<cmd>lua require'dap'.step_over()<cr>", { desc = "Step Over" })
            vim.keymap.set('n', "<leader>Du", "<cmd>lua require'dap'.step_out()<cr>", { desc = "Step Out" })
            vim.keymap.set('n', "<leader>Dp", "<cmd>lua require'dap'.pause()<cr>", { desc = "Pause" })
            vim.keymap.set('n', "<leader>Dr", "<cmd>lua require'dap'.repl.toggle()<cr>", { desc = "Toggle Repl" })
            vim.keymap.set('n', "<leader>Ds", "<cmd>lua require'dap'.continue()<cr>", { desc = "Start" })
            vim.keymap.set('n', "<leader>Dq", "<cmd>lua require'dap'.close()<cr>", { desc = "Quit" })
            vim.keymap.set('n', "<leader>DU", "<cmd>lua require'dapui'.toggle({reset = true})<cr>",
                { desc = "Toggle UI" })
        end
    },

}