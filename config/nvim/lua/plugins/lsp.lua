return {
  "neovim/nvim-lspconfig",
  dependencies = {
    -- LSP Support
    { "williamboman/mason.nvim" },
    { "williamboman/mason-lspconfig.nvim" },
    { "hrsh7th/cmp-nvim-lsp" },
    -- Autocompletion
    { "hrsh7th/nvim-cmp" },
  },
  config = function()
    local lspconfig = require('lspconfig')
    local lsp_defaults = lspconfig.util.default_config

    lsp_defaults.capabilities = vim.tbl_deep_extend(
      'force',
      lsp_defaults.capabilities,
      require('cmp_nvim_lsp').default_capabilities()
    )

    vim.api.nvim_create_autocmd('LspAttach', {
      desc = 'LSP actions',
      callback = function(event)
        local opts = { buffer = event.buf }
        local keymap = vim.keymap
        opts.desc = "Show LSP references"
        keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

        opts.desc = "Go to declaration"
        keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

        opts.desc = "Show LSP definitions"
        keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

        opts.desc = "Show LSP implementations"
        keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

        opts.desc = "Show LSP type definitions"
        keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

        opts.desc = "Code Actions"
        keymap.set({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

        opts.desc = "Smart Rename"
        keymap.set("n", "<leader>lr", vim.lsp.buf.rename, opts) -- smart rename

        opts.desc = "Show buffer diagnostics"
        keymap.set("n", "<leader>lD", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

        opts.desc = "Show line diagnostics"
        keymap.set("n", "<leader>ld", vim.diagnostic.open_float, opts) -- show diagnostics for line

        opts.desc = "Go to previous diagnostic"
        keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

        opts.desc = "Go to next diagnostic"
        keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

        opts.desc = "Show documentation for what is under cursor"
        keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

        opts.desc = "Restart LSP"
        keymap.set("n", "<leader>lc", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary

        opts.desc = "Format File"
        keymap.set({ "n", "x" }, "<leader>f", "<cmd>GuardFmt<CR>", opts) -- mapping to restart lsp if necessary
      end
    })

    local default_setup = function(server)
      lspconfig[server].setup({})
    end

    require('mason').setup({})
    require('mason-lspconfig').setup({
      ensure_installed = { "tsserver", "eslint", "lua_ls", "ansiblels", "astro", "bashls", "clangd", "cssls", "dockerls",
        "emmet_ls", "eslint", "html", "jsonls", "tailwindcss", "vimls", "yamlls" },
      handlers = { default_setup,
        -- configure lua server (with special settings)
        lspconfig["lua_ls"].setup({
          settings = { -- custom settings for lua
            Lua = {
              -- make the language server recognize "vim" global
              diagnostics = {
                globals = { "vim" },
              },
              workspace = {
                -- make language server aware of runtime files
                library = {
                  [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                  [vim.fn.stdpath("config") .. "/lua"] = true,
                },
              },
            },
          },
        })
      },
    })
  end,
}
