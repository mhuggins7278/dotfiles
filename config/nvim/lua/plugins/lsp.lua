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
  },
  config = function()
    vim.opt.completeopt = { "menu", "menuone", "noselect" }
    vim.opt.shortmess:append("c")
    local lsp_zero = require("lsp-zero").preset({})
    lsp_zero.set_sign_icons({
      error = " ", warn = " ", hint = " ", info = " "
    })

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
          local lua_lsp_opts = lsp_zero.nvim_lua_ls()
          require("lspconfig").lua_ls.setup(lua_lsp_opts)
        end,
      },
    })

  end,
}
