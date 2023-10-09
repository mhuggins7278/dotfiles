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
    vim.opt.shortmess:append("c")
    local luasnip = require("luasnip")

    local cmp = require("cmp")
    require('luasnip.loaders.from_vscode').lazy_load()

    cmp.setup({
      preselect = 'none',
      completion = {
        completeopt = 'menu,preview,menuone,noselect'
      },
      snippet = {       -- configure how nvim-cmp interacts with snippet engine
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      sources = {
        { name = 'copilot' },
        { name = 'path' },
        { name = 'nvim_lsp' },
        { name = 'nvim_lua' },
        { name = 'buffer' },
        { name = 'luasnip' },
      },
      formatting = {
        fields = { 'abbr', 'kind', 'menu' },
        format = require('lspkind').cmp_format({
          mode = 'symbol',       -- show only symbol annotations
          maxwidth = 50,         -- prevent the popup from showing more than provided characters
          symbol_map = { Copilot = "" },
          ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead
        })
      },
      mapping = cmp.mapping.preset.insert({
        -- scroll up and down the documentation window
        ["<C-u>"] = cmp.mapping.scroll_docs(-4),
        ["<C-d>"] = cmp.mapping.scroll_docs(4),
        ["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
        ["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
        ["<C-n>"] = cmp.config.disable,
        ["<C-p>"] = cmp.config.disable,
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
