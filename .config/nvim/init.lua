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
vim.o.exrc = true

-- Disable swap file as this was annoying me
vim.opt.swapfile = false

-- [[ Setting options ]]
require 'options'

-- [[ Install `lazy.nvim` plugin manager ]]
require 'lazy-bootstrap'

-- [[ Configure and install plugins ]]
require 'lazy-plugins'

require 'autocommands'

-- [[ Basic Keymaps ]]
require 'keymaps'

local colorscheme = 'duskfox'
-- local colorscheme = 'nightfox'
-- local colorscheme = 'onedark'
-- local colorscheme = 'catppuccin-mocha'
-- local colorscheme = 'tokyonight-night'
-- local colorscheme = 'kanagawa'
vim.cmd('colorscheme ' .. colorscheme)

local jdtls_bundles = {
  vim.fs.joinpath(vim.fn.stdpath 'data', 'mason', 'share', 'java-debug-adapter', 'com.microsoft.java.debug.plugin.jar'),
}

vim.lsp.config('jdtls', {
  before_init = function(params, config)
    local root_dir = config.root_dir

    -- print('Before init jdtls with root dir' .. tostring(root_dir))

    if not root_dir then
      return
    end

    local code_formatting_file = vim.fs.joinpath(root_dir, 'code-formatting.xml')

    local formattingSettings = {
      enabled = true,
      settings = {
        url = code_formatting_file,
      },
    }

    config.settings.java['format'] = formattingSettings
  end,
  init_options = {
    bundles = jdtls_bundles,
  },
  settings = {
    java = {
      -- Custom eclipse.jdt.ls options go here
      -- https://github.com/eclipse-jdtls/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request

      saveActions = {
        organizeImports = false,
        cleanup = true,
      },
      cleanup = {
        actionsOnSave = { 'addOverride', 'addFinalModifier', 'instanceofPatternMatch', 'organizeImports', 'lambdaExpression', 'switchExpression' },
      },
    },
  },
})

vim.lsp.enable 'jdtls'
vim.lsp.enable 'clangd'

require('overseer').setup()
