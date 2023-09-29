return {

  "hrsh7th/nvim-cmp",
  dependencies = {
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
    { "rafamadriz/friendly-snippets" }
  },
  config = function()
    vim.opt.completeopt = { "menu", "menuone", "noselect" }
    vim.opt.shortmess:append("c")

    local cmp = require("cmp")
    local cmp_format = require("lsp-zero").cmp_format()
    require('luasnip.loaders.from_vscode').lazy_load()


    cmp.setup({
      preselect = cmp.PreselectMode.None,
      completion = {
        completeopt = 'menu,menuone,noinsert'
      },
      sources = {
        { name = 'path' },
        { name = 'copilot' },
        { name = 'nvim_lsp' },
        { name = 'nvim_lua' },
        { name = 'buffer' },
        { name = 'luasnip' },
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
