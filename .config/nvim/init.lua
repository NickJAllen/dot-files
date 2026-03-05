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
