local null_ls = require("null-ls")
local helpers = require("null-ls.helpers")

local coffeelint = {
	method = null_ls.methods.DIAGNOSTICS,
	filetypes = { "coffee" },
	-- null_ls.generator creates an async source
	-- that spawns the command with the given arguments and options
	generator = null_ls.generator({
		command = "coffeelint",
		args = { "--stdin", "--reporter", "csv" },
		to_stdin = true,
		-- from_stderr = true,
		-- choose an output format (raw, json, or line)
		format = "line",
		check_exit_code = function(code, stderr)
			local success = code <= 1
			if not success then
				-- can be noisy for things that run often (e.g. diagnostics), but can
				-- be useful for things that run on demand (e.g. formatting)
				print(stderr)
			end
			return success
		end,
		-- use helpers to parse the output from string matchers,
		-- or parse it manually with a function
		-- on_output = function(one)
		--     print(one)
		--     return false
		--
		-- end
		on_output = helpers.diagnostics.from_patterns({
			{
				pattern = [[stdin,(%d+),(%d*),(%w+),(.+)]],
				groups = { "row", "lineNumberEnd", "severity", "message" },
			},
		}),
	}),
}

null_ls.register(coffeelint)
