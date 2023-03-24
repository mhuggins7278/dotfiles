return {
	{
		"rcarriga/nvim-dap-ui",
		dependencies = { "mfussenegger/nvim-dap" },
		event = "BufRead",
		config = function()
			require("dapui").setup()
			vim.keymap.set(
				"n",
				"<leader>dbt",
				"<cmd>lua require'dap'.toggle_breakpoint()<cr>",
				{ desc = "Toggle Breakpoint" }
			)
			vim.keymap.set("n", "<leader>dsb", "<cmd>lua require'dap'.step_back()<cr>", { desc = "Step Back" })
			vim.keymap.set("n", "<leader>dsc", "<cmd>lua require'dap'.continue()<cr>", { desc = "Continue" })
			vim.keymap.set("n", "<leader>dsv", "<cmd>lua require'dap'.step_over()<cr>", { desc = "Step Over" })
			vim.keymap.set("n", "<leader>dsi", "<cmd>lua require'dap'.step_into()<cr>", { desc = "Step Into" })
			vim.keymap.set("n", "<leader>dso", "<cmd>lua require'dap'.step_out()<cr>", { desc = "Step Out" })
			vim.keymap.set("n", "<leader>dsr", "<cmd>lua require'dap'.run_to_cursor()<cr>", { desc = "Run To Cursor" })
			vim.keymap.set("n", "<leader>dd", "<cmd>lua require'dap'.disconnect()<cr>", { desc = "Disconnect" })
			vim.keymap.set("n", "<leader>dg", "<cmd>lua require'dap'.session()<cr>", { desc = "Get Session" })
			vim.keymap.set("n", "<leader>dp", "<cmd>lua require'dap'.pause()<cr>", { desc = "Pause" })
			vim.keymap.set("n", "<leader>dr", "<cmd>lua require'dap'.repl.toggle()<cr>", { desc = "Toggle Repl" })
			vim.keymap.set("n", "<leader>dq", "<cmd>lua require'dap'.close()<cr>", { desc = "Quit" })
			vim.keymap.set("n", "<Leader>duh", ":lua require('dap.ui.widgets').hover()<CR>", { desc = "Show hover" })
			vim.keymap.set(
				"n",
				"<Leader>duf",
				":lua local widgets=require('dap.ui.widgets');widgets.centered_float(widgets.scopes)<CR>",
				{ desc = "Show scopes" }
			)

			vim.keymap.set(
				"n",
				"<Leader>dbc",
				"<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
				{ desc = "Set conditional breakpoint" }
			)
			vim.keymap.set(
				"n",
				"<leader>di",
				"<cmd>lua require'dapui'.toggle({reset = true})<cr>",
				{ desc = "Toggle UI" }
			)
			local dap = require("dap")
			dap.adapters.node2 = {
				type = "executable",
				command = "node",
				args = { vim.fn.stdpath("data") .. "/mason/packages/node-debug2-adapter/out/src/nodeDebug.js" },
			}

			dap.configurations.typescript = {
				{
					-- For this to work you need to make sure the node process is started with the `--inspect` flag.
					name = "Attach to process",
					type = "node2",
					request = "attach",
					processId = require("dap.utils").pick_process,
				},
			}
			dap.configurations.coffee = {
				{
					-- For this to work you need to make sure the node process is started with the `--inspect` flag.
					name = "Attach to process",
					type = "node2",
					request = "attach",
          port = 9191,
					processId = require("dap.utils").pick_process,
				},
			}
			dap.configurations.javascript = {
				{
					name = "Launch",
					type = "node2",
					request = "launch",
					program = "${file}",
					cwd = vim.fn.getcwd(),
					sourceMaps = true,
					protocol = "inspector",
					console = "integratedTerminal",
				},
				{
					-- For this to work you need to make sure the node process is started with the `--inspect` flag.
					name = "Attach to process",
					type = "node2",
					request = "attach",
					processId = require("dap.utils").pick_process,
				},
			}
		end,
	},
}
