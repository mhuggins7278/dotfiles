return {
	"VonHeikemen/lsp-zero.nvim",
	event = "BufReadPre",
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
		{ "github/copilot.vim" },
	},
	config = function()
		local lsp = require("lsp-zero")

		lsp.preset("recommended")

		lsp.ensure_installed({
			"tsserver",
			"eslint",
			"sumneko_lua",
			"rust_analyzer",
		})
		lsp.skip_server_setup({ "denols" })

		-- Fix Undefined global 'vim'
		lsp.configure("sumneko_lua", {
			settings = {
				Lua = {
					diagnostics = {
						globals = { "vim" },
					},
				},
			},
		})

		lsp.setup()
		local null_ls = require("null-ls")
		local null_opts = lsp.build_options("null-ls", {})

		null_ls.setup({
			on_attach = function(client, bufnr)
				null_opts.on_attach(client, bufnr)
			end,
			sources = {
				-- You can add tools not supported by mason.nvim
			},
		})

		-- See mason-null-ls.nvim's documentation for more details:
		-- https://github.com/jay-babu/mason-null-ls.nvim#setup
		require("mason-null-ls").setup({
			ensure_installed = nil,
			automatic_installation = false, -- You can still set this to `true`
			automatic_setup = true,
		})

		-- Required when `automatic_setup` is true
		require("mason-null-ls").setup_handlers()

		local cmp = require("cmp")
		local cmp_select = { behavior = cmp.SelectBehavior.Select }
		local cmp_mappings = lsp.defaults.cmp_mappings({
			["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
			["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
			["<C-y>"] = cmp.mapping.confirm({ select = true }),
			["<C-Space>"] = cmp.mapping.complete(),
		})
		require("cmp").config.formatting = {
			format = require("tailwindcss-colorizer-cmp").formatter,
		}

		-- disable completion with tab
		-- this helps with copilot setup
		cmp_mappings["<Tab>"] = nil
		cmp_mappings["<S-Tab>"] = nil

		lsp.setup_nvim_cmp({
			mapping = cmp_mappings,
		})

		lsp.set_preferences({
			suggest_lsp_servers = false,
			sign_icons = {
				error = "E",
				warn = "W",
				hint = "H",
				info = "I",
			},
		})

		lsp.on_attach(function(client, bufnr)

			vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr, remap = false, desc = "Go To Definition" })
			vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr, remap = false, desc = "Lsp Hover" })
			vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, { buffer = bufnr, remap = false, desc = "Code Actions" })
			vim.keymap.set("n", "<leader>lr", vim.lsp.buf.references, { buffer = bufnr, remap = false, desc = "References" })
			vim.keymap.set("n", "<leader>lR", vim.lsp.buf.rename, { buffer = bufnr, remap = false, desc = "Rename" })
			vim.keymap.set("i", "<leader>lh", vim.lsp.buf.signature_help, { buffer = bufnr, remap = false, desc = "Signature Help" })
			vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { buffer = bufnr, remap = false, desc = "Lsp Format" })
		end)

		vim.diagnostic.config({
			virtual_text = true,
		})
		require("mason").setup()
		require("mason").setup()
		require("mason-nvim-dap").setup({
			automatic_installation = true,
		})
	end,
}
