return {
  {
    -- Required by nvim-beautiful-mermaid for inline image rendering via Kitty graphics protocol.
    -- image.nvim's markdown integration is disabled here because render-markdown.nvim already
    -- handles markdown rendering. snacks.nvim handles regular inline images (![](...)). 
    '3rd/image.nvim',
    lazy = true,
    opts = {
      backend = 'kitty',
      editor_only_render_when_focused = true,
      integrations = {
        markdown = { enabled = false },
      },
    },
  },
  {
    'ruslan-kurchenko/nvim-beautiful-mermaid',
    dependencies = { '3rd/image.nvim' },
    ft = { 'markdown' },
    build = 'bun install',
    config = function()
      require('beautiful_mermaid').setup {
        render = {
          target = 'in_buffer',
          format = 'svg',
          backend = 'image',
          live = true,
          debounce_ms = 300,
        },
        mermaid = {
          theme = 'default',
        },
        -- Use <leader>m prefix to avoid conflict with refactoring.nvim (<leader>rf, etc.)
        keymaps = {
          render = '<leader>mr',
          render_all = '<leader>mR',
          preview = '<leader>mp',
          split = '<leader>ms',
          clear = '<leader>mc',
        },
      }
    end,
  },
}
