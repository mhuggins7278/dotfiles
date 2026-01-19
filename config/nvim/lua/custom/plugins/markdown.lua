return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
  opts = {
    checkbox = {
      enabled = true,
      position = 'overlay',
      unchecked = { icon = '󰄱 ' },
      checked = { icon = '󰱒 ' },
      custom = {
        todo = { raw = '[-]', rendered = '󰥔 ', highlight = 'RenderMarkdownTodo' },
        forwarded = { raw = '[>]', rendered = '󰁔 ', highlight = 'RenderMarkdownH1' },
        cancelled = { raw = '[~]', rendered = '󰜺 ', highlight = 'RenderMarkdownH2' },
        important = { raw = '[!]', rendered = '󰀨 ', highlight = 'RenderMarkdownH3' },
      },
    },
  },
  ft = { 'markdown', 'Avante', 'codecompanion' },
}
