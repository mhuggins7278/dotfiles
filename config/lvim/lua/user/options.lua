local opt = vim.opt
vim.cmd([[
  syntax enable
  filetype plugin indent on
  " spell
]])

opt.termguicolors = true
opt.showtabline = 0
opt.cmdheight = 0
opt.relativenumber = true
opt.colorcolumn = "80"
opt.statusline = ""
opt.timeoutlen = 300


vim.o.nocompatible = true

lvim.log.level = "warn"
lvim.format_on_save = false

lvim.leader = "space"
lvim.transparent_window = false

lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.breadcrumbs.active = true
lvim.builtin.bufferline.active = false
lvim.builtin.lualine.sections.lualine_z = { "filesize" }
lvim.builtin.nvimtree.setup.view.side = "right"
lvim.builtin.nvimtree.setup.sync_root_with_cwd = false
lvim.builtin.terminal.active = true
lvim.builtin.terminal.size = 40
lvim.builtin.dap.active = true
lvim.builtin.notify.active = false
