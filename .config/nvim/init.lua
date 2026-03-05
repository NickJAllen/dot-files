-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

vim.g.neovide_input_macos_option_key_is_meta = 'only_left'

vim.g.snacks_animate = true
vim.g.snacks_indent = true

-- Allow loading directory specific configurations
vim.opt.exrc = true

-- Disable swap file as this was annoying me
vim.opt.swapfile = false

vim.opt.fillchars = {
  foldopen = '',
  foldclose = '',
  fold = ' ',
  foldsep = ' ',
  diff = '╱',
  eob = ' ',
}

vim.opt.background = 'dark'

-- [[ Setting options ]]
require 'options'

-- [[ Install `lazy.nvim` plugin manager ]]
require 'lazy-bootstrap'

-- [[ Configure and install plugins ]]
require 'lazy-plugins'

require 'autocommands'

-- [[ Basic Keymaps ]]
require 'keymaps'

math.randomseed(os.time())

local utils = require 'nick.utils'

utils.choose_random_colorscheme()

vim.lsp.enable 'clangd'

require('overseer').setup()
