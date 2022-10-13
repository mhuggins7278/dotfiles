local opt = vim.opt
opt.foldlevel = 20
opt.foldmethod = "expr"
opt.termguicolors = true
opt.showtabline = 0

vim.opt.cmdheight = 1
vim.cmd([[
  set nocompatible
  filetype off
  syntax enable
  filetype plugin indent on
  set relativenumber
  set colorcolumn=80
  set statusline=""
]])

lvim.log.level = "warn"
lvim.format_on_save = false

lvim.leader = "space"
lvim.transparent_window = false

lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.breadcrumbs.active = true
lvim.builtin.bufferline.active = false
lvim.builtin.lualine.sections.lualine_z = { "filesize" }
lvim.builtin.notify.active = true
lvim.builtin.nvimtree.setup.view.side = "right"
lvim.builtin.nvimtree.setup.sync_root_with_cwd = false
lvim.builtin.terminal.active = true
lvim.builtin.terminal.size = 40
lvim.builtin.dap.active = true

