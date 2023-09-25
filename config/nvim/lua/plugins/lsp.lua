return {
  "VonHeikemen/lsp-zero.nvim",
  branch = "v3.x",
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
    { "onsails/lspkind-nvim" },

    -- Snippets
    { "L3MON4D3/LuaSnip" },
    { "rafamadriz/friendly-snippets" },
  },
  config = function()
    local lsp_zero = require("lsp-zero")

    local lua_opts = lsp_zero.nvim_lua_ls()
    require('lspconfig').lua_ls.setup(lua_opts)

    lsp_zero.on_attach(function(_, bufnr)
      -- see :help lsp-zero-keybindings
      -- to learn the available actions
      local opts = { buffer = bufnr }
      lsp_zero.default_keymaps({ preserve_mappings = false })
      vim.keymap.set({ 'n', 'x' }, '<leader>f', "<cmd>GuardFmt<cr>", opts)
      vim.keymap.set({ 'n', 'x' }, '<leader>la', function()
        vim.lsp.buf.code_action({ async = false, timeout_ms = 10000 })
      end, opts)
      vim.keymap.set({ 'n' }, '<leader>lr', function()
        vim.lsp.buf.rename()
      end, opts)
    end)

    require("mason").setup({})
    require("mason-lspconfig").setup({
      ensure_installed = {},
      handlers = {
        lsp_zero.default_setup,
        lua_ls = function()
          local lua_opts = lsp_zero.nvim_lua_ls()
          require("lspconfig").lua_ls.setup(lua_opts)
        end,
      },
    })

    local cmp = require("cmp")
    local cmp_format = lsp_zero.cmp_format()
    require('luasnip.loaders.from_vscode').lazy_load()

    cmp.setup({
      preselect = 'item',
      completion = {
        completeopt = 'menu,menuone,noinsert'
      },
      sources = {
        { name = 'copilot' },
        { name = 'nvim_lsp' },
        { name = 'buffer' },
        { name = 'snippets' },
      },
      formatting = cmp_format,
      mapping = cmp.mapping.preset.insert({
        -- scroll up and down the documentation window
        ["<C-u>"] = cmp.mapping.scroll_docs(-4),
        ["<C-d>"] = cmp.mapping.scroll_docs(4),
        ["<Tab>"] = cmp.config.disable,
        ["<S-Tab>"] = cmp.config.disable,
        ['<CR>'] = cmp.mapping.confirm({
          -- documentation says this is important.
          -- I don't know why.
          behavior = cmp.ConfirmBehavior.Replace,
          select = false,
        }),
        ['<C-y>'] = cmp.mapping.confirm({
          -- documentation says this is important.
          -- I don't know why.
          behavior = cmp.ConfirmBehavior.Replace,
          select = false,
        })
      }),
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
        suggestion = cmp.config.window.bordered(),
      },
    })
  end,
}
