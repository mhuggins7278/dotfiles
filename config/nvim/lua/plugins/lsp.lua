return {
	"VonHeikemen/lsp-zero.nvim",
	dependencies = {
		-- LSP Support
		{ "neovim/nvim-lspconfig" },
		{ "williamboman/mason.nvim" },
		{ "williamboman/mason-lspconfig.nvim" },

		-- Autocompletion
		{ "hrsh7th/nvim-cmp" },
		{ "hrsh7th/cmp-buffer" },
		{ "hrsh7th/cmp-path" },
		{ "saadparwaiz1/cmp_luasnip" },
		{ "hrsh7th/cmp-nvim-lsp" },
		{ "hrsh7th/cmp-nvim-lua" },

		-- Snippets
		{ "L3MON4D3/LuaSnip" },
		{ "rafamadriz/friendly-snippets" },
	},
	config = function()
		local lsp = require("lsp-zero")

		lsp.preset("recommended")

		lsp.ensure_installed({
			"tsserver",
			"eslint",
			"lua_ls",
			"rust_analyzer",
			"sqlls",
		})
		-- lsp.skip_server_setup({ "denols", "sqls" })
		-- Fix Undefined global 'vim'
		local nvim_lsp = require("lspconfig")
		lsp.configure("denols", {
			root_dir = nvim_lsp.util.root_pattern("deno.json", "deno.jsonc"),
		})

		lsp.configure("tsserver", {
			root_dir = nvim_lsp.util.root_pattern("package.json"),
			single_file_support = false,
		})

		lsp.configure("lua_ls", {
			settings = {
				Lua = {
					diagnostics = {
						globals = { "vim" },
					},
				},
			},
		})
		lsp.nvim_workspace()

		local cmp = require("cmp")
		local cmp_select = { behavior = cmp.SelectBehavior.Select }
		local cmp_mappings = lsp.defaults.cmp_mappings({
			["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
			["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
			["<C-y>"] = cmp.mapping.confirm({ select = true }),
			["<C-Space>"] = cmp.mapping.complete(),
			-- disable completion with tab
			-- this helps with copilot setup
			["<Tab>"] = cmp.config.disable,
			["<S-Tab>"] = cmp.config.disable,
		})

		lsp.setup_nvim_cmp({
			mapping = cmp_mappings,
			sources = {
				{ name = "copilot", group_index = 2 },
				-- Other Sources
				{ name = "nvim_lsp", group_index = 2 },
				{ name = "path", group_index = 2 },
				{ name = "luasnip", group_index = 2 },
			},
		})

		lsp.set_preferences({
			suggest_lsp_servers = false,
		})

		lsp.on_attach(function(client, bufnr)
			vim.keymap.set(
				"n",
				"gd",
				"<cmd>Telescope lsp_definitions<cr>",
				{ buffer = bufnr, remap = false, desc = "Go To Definition" }
			)
			vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr, remap = false, desc = "Lsp Hover" })
			vim.keymap.set(
				"n",
				"<leader>la",
				vim.lsp.buf.code_action,
				{ buffer = bufnr, remap = false, desc = "Code Actions" }
			)
			vim.keymap.set("n", "<leader>lr", "<cmd>Telescope lsp_references<cr>", { desc = "References" })
			vim.keymap.set("n", "<leader>li", "<cmd>Telescope lsp_implementations<cr>", { desc = "Implementations" })
			vim.keymap.set("n", "<leader>lt", "<cmd>Telescope lsp_type_definitions<cr>", { desc = "Type Defs" })
			vim.keymap.set("n", "<leader>lR", vim.lsp.buf.rename, { buffer = bufnr, remap = false, desc = "Rename" })
			vim.keymap.set(
				"n",
				"<leader>lh",
				vim.lsp.buf.signature_help,
				{ buffer = bufnr, remap = false, desc = "Signature Help" }
			)
			vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { buffer = bufnr, remap = false, desc = "Lsp Format" })
		end)

		lsp.setup()

		vim.diagnostic.config({
			virtual_text = true,
		})
		require("mason").setup()
		require("mason-nvim-dap").setup({
			automatic_installation = true,
		})
		-- See mason-null-ls.nvim's documentation for more details:
		-- https://github.com/jay-babu/mason-null-ls.nvim#setup
		require("mason-null-ls").setup({
			ensure_installed = nil,
			automatic_installation = true, -- You can still set this to `true`
			automatic_setup = true,
			handlers = {},
		})
		local null_ls = require("null-ls")
		require("null-ls").setup({
			sources = {
				null_ls.builtins.formatting.prettierd,
				null_ls.builtins.diagnostics.eslint_d,
				null_ls.builtins.formatting.stylua,
				null_ls.builtins.diagnostics.sqlfluff.with({
					extra_args = { "--dialect", "ansi", "--exclude-rules", "capitalisation" }, -- change to your dialect
				}),
			},
		})
		-- Required when `automatic_setup` is true
		-- require("mason-null-ls").setup_handlers()
	end,
}
