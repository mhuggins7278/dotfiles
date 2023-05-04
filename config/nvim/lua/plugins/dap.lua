return {
	{
		"rcarriga/nvim-dap-ui",
		dependencies = { "mfussenegger/nvim-dap" },
		event = "BufRead",
		config = function()
			require("dapui").setup()
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
