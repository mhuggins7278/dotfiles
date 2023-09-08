return {
  "VonHeikemen/lsp-zero.nvim",
  dependencies = {
    -- LSP Support
    { "neovim/nvim-lspconfig" },
    { "williamboman/mason.nvim" },
    { "williamboman/mason-lspconfig.nvim" },
    -- { "jay-babu/mason-null-ls.nvim" },

    -- Autocompletion
    { "hrsh7th/nvim-cmp" },
    { "hrsh7th/cmp-vsnip" },
    { "hrsh7th/vim-vsnip" },
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
    local lsp = require("lsp-zero").preset({})
    require("lsp-zero").extend_lspconfig({
      on_attach = function(_, bufnr)
        vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<cr>", { desc = "Go To Definition" })
        vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr, remap = false, desc = "Lsp Hover" })
        vim.keymap.set("i", "<C-h>", function()
          vim.lsp.buf.signature_help()
        end, { buffer = bufnr, remap = false })
        vim.keymap.set(
          "n",
          "<leader>la",
          vim.lsp.buf.code_action,
          { buffer = bufnr, remap = false, desc = "Code Actions" }
        )
        vim.keymap.set("n", "<leader>lR", "<cmd>Telescope lsp_references<cr>", { desc = "References" })
        vim.keymap.set(
          "n",
          "<leader>li",
          "<cmd>Telescope lsp_implementations<cr>",
          { desc = "Implementations" }
        )
        vim.keymap.set("n", "<leader>lt", "<cmd>Telescope lsp_type_definitions<cr>", { desc = "Type Defs" })
        vim.keymap.set(
          "n",
          "<leader>lr",
          vim.lsp.buf.rename,
          { buffer = bufnr, remap = false, desc = "Rename" }
        )
        vim.keymap.set(
          "n",
          "<leader>lh",
          vim.lsp.buf.signature_help,
          { buffer = bufnr, remap = false, desc = "Signature Help" }
        )
        vim.keymap.set(
          "n",
          "<leader>f",
          vim.lsp.buf.format,
          { buffer = bufnr, remap = false, desc = "Lsp Format" }
        )
      end,
    })

    require("mason").setup()
    require("mason-nvim-dap").setup({
      automatic_installation = true,
    })
    require("mason-lspconfig").setup()

    local get_servers = require("mason-lspconfig").get_installed_servers
    for _, server_name in ipairs(get_servers()) do
      require("lspconfig")[server_name].setup({})
    end

    ---
    -- Diagnostic config
    ---

    require("lsp-zero").set_sign_icons()
    vim.diagnostic.config(require("lsp-zero").defaults.diagnostics({
      virtual_text = true,
    }))

    ---
    -- Snippet config
    ---

    require("luasnip").config.set_config({
      region_check_events = "InsertEnter",
      delete_check_events = "InsertLeave",
    })

    require("luasnip.loaders.from_vscode").lazy_load()

    ---
    -- Autocompletion
    ---

    vim.opt.completeopt = { "menu", "menuone", "noselect" }
    vim.opt.shortmess:append("c")

    local cmp = require("cmp")
    local cmp_config = require("lsp-zero").defaults.cmp_config({
      mapping = {
        ["<C-y>"] = cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Replace }),
        ["<CR>"] = cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Replace }),
        ["<C-Space>"] = cmp.mapping.complete(),
        -- disable completion with tab
        -- this helps with copilot setup
        ["<Tab>"] = cmp.config.disable,
        ["<S-Tab>"] = cmp.config.disable,
      },
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
        suggestion = cmp.config.window.bordered(),
      },
      sources = {
        { name = "copilot",  group_index = 2 },
        -- Other Sources
        { name = "nvim_lsp", group_index = 2 },
        { name = "path",     group_index = 2 },
        { name = "luasnip",  group_index = 2 },
      },
      snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end,
      },
    })

    local nvim_lsp = require("lspconfig")
    cmp.setup(cmp_config)
    require("lspconfig").tsserver.setup({
      root_dir = nvim_lsp.util.root_pattern("package.json"),
      single_file_support = true,
      filetypes = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
      },
    })

    require("lspconfig").denols.setup({
      root_dir = nvim_lsp.util.root_pattern("deno.json", "deno.jsonc"),
    })

    require("lspconfig").lua_ls.setup({
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },
        },
      },
    })

    require("lspconfig").null_ls.setup({
      settings = {
        format = true,
      },
    })

    lsp.nvim_workspace()
    local null_ls = require("null-ls")
    require("null-ls").setup({
      sources = {
        null_ls.builtins.formatting.prettierd.with({
          filetypes = {
            "astro",
            "css",
            "graphql",
            "handlebars",
            "html",
            "javascript",
            "javascriptreact",
            "json",
            "jsonc",
            "less",
            "lua",
            "luau",
            "markdown",
            "markdown.mdx",
            "scss",
            "sql",
            "typescript",
            "typescriptreact",
            "vue",
            "yaml",
          },
        }),
        -- null_ls.builtins.diagnostics.eslint_d,
        -- null_ls.builtins.code_actions.eslint_d,
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.code_actions.gitsigns,
        -- null_ls.builtins.diagnostics.cspell.with({
        --   extra_args = { "--config", vim.fn.expand("~/cspell.json") },
        -- }),
        -- null_ls.builtins.code_actions.cspell,
        null_ls.builtins.diagnostics.sqlfluff.with({
          extra_args = { "--dialect", "tsql", "--exclude-rules", "capitalisation" }, -- change to your dialect
        }),
        null_ls.builtins.formatting.sqlfluff.with({
          extra_args = { "--dialect", "tsql" }, -- change to your dialect
        }),
      },
      -- on_attach = function(_, bufnr)
      --   local all_formatter = null_ls.get_sources({ method = null_ls.methods.FORMATTING })
      --   for _, formatter in pairs(all_formatter) do
      --     if formatter.filetypes[vim.bo.filetype] then
      --       vim.api.nvim_buf_set_keymap(
      --         bufnr,
      --         "n",
      --         "<leader>f",
      --         "<cmd>lua vim.lsp.buf.format()<CR>",
      --         { desc = "Lsp Format" }
      --       )
      --     end
      --   end
      -- end,
    })
  end,
}
