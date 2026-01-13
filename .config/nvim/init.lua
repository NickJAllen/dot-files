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

vim.opt.fillchars = {
  foldopen = '',
  foldclose = '',
  fold = ' ',
  foldsep = ' ',
  diff = '╱',
  eob = ' ',
}

vim.o.background = 'dark'

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

local function find_jdtls_bundles()
  local dap_jar_path =
    vim.fs.joinpath(vim.fn.stdpath 'data', 'mason', 'packages', 'java-debug-adapter', 'extension', 'server', 'com.microsoft.java.debug.plugin-*.jar')

  local bundles = {
    vim.fn.glob(dap_jar_path, 1),
  }

  local java_test_jars = vim.fs.joinpath(vim.fn.stdpath 'data', 'mason', 'packages', 'java-test', 'extension', 'server', '*.jar')
  local java_test_bundles = vim.split(vim.fn.glob(java_test_jars, 1), '\n')
  local excluded = {
    'com.microsoft.java.test.runner-jar-with-dependencies.jar',
    'jacocoagent.jar',
  }
  for _, java_test_jar in ipairs(java_test_bundles) do
    local fname = vim.fn.fnamemodify(java_test_jar, ':t')
    if not vim.tbl_contains(excluded, fname) then
      table.insert(bundles, java_test_jar)
    end
  end

  return bundles
end

vim.lsp.config('jdtls', {
  before_init = function(_, config)
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
    bundles = find_jdtls_bundles(),
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
        actionsOnSave = {
          'addOverride',
          'addFinalModifier',
          'instanceofPatternMatch',
          'organizeImports',
          'lambdaExpression',
          -- 'switchExpression',
        },
      },
    },
  },
})

vim.lsp.enable 'jdtls'
vim.lsp.enable 'clangd'

require('overseer').setup()
