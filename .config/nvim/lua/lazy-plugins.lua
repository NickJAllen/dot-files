require('lazy').setup({
  -- NOTE: Plugins can be added with a link (or for a github repo: 'owner/repo' link).
  'nvim-lua/plenary.nvim',
  'NMAC427/guess-indent.nvim', -- Detect tabstop and shiftwidth automatically

  { import = 'themes' },
  { import = 'plugins' },
}, {

  concurrency = 8,

  dev = {
    ---@type string | fun(plugin: LazyPlugin): string
    path = '~/dev/neovim-plugins',
    ---@type string[] plugins that match these patterns will use your local versions instead of being fetched from GitHub
    patterns = {}, -- For example {"folke"}
    fallback = false, -- Fallback to git when local plugin doesn't exist
  },

  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- vim: ts=2 sts=2 sw=2 et
