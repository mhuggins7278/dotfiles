return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons", opt = true },
	config = function()
		local function lsp_client()
			local buf_clients = vim.lsp.buf_get_clients()
			if next(buf_clients) == nil then
				return ""
			end
			local buf_client_names = {}
			for _, client in pairs(buf_clients) do
				if client.name ~= "null-ls" then
					table.insert(buf_client_names, client.name)
				end
			end
			return "[" .. table.concat(buf_client_names, ", ") .. "]"
		end

		local function lsp_progress(_, is_active)
			if not is_active then
				return
			end
			local messages = vim.lsp.util.get_progress_messages()
			if #messages == 0 then
				return ""
			end
			local status = {}
			for _, msg in pairs(messages) do
				local title = ""
				if msg.title then
					title = msg.title
				end
				table.insert(status, (msg.percentage or 0) .. "%% " .. title)
			end
			local spinners = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
			local ms = vim.loop.hrtime() / 1000000
			local frame = math.floor(ms / 120) % #spinners
			return table.concat(status, "  ") .. " " .. spinners[frame + 1]
		end

    local function get_project_name()
      local project_root = require("lspconfig.util").root_pattern(".git")(vim.fn.expand("%:p:h"))
      if project_root == nil then
        return "not found"
      end
      return project_root
    end


		require("lualine").setup({
			options = {
				icons_enabled = true,
				theme = "auto",
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				disabled_filetypes = {
					statusline = {},
					winbar = {},
				},
				ignore_focus = {},
				always_divide_middle = true,
				globalstatus = false,
				refresh = {
					statusline = 1000,
					tabline = 1000,
					winbar = 1000,
				},
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff", "diagnostics", "filename" },
				lualine_c = {
					{ lsp_client, icon = " " },
					{ lsp_progress },
				},
				lualine_x = { "encoding", "fileformat", "filetype" },
				-- lualine_y = { "progress" },
				lualine_y = {{get_project_name, icon = " "}},
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { "filename" },
				lualine_x = {},
				lualine_y = {},
				lualine_z = {},
			},
			tabline = {},
			winbar = {},
			inactive_winbar = {},
			extensions = {},
		})
	end,
}
