return {
  'nvim-neorg/neorg',
  lazy = false,
  version = '*',
  -- enabled = false,
  dependencies = {
    'nvim-neorg/tree-sitter-norg',
    'nvim-neorg/tree-sitter-norg-meta',
  },
  config = function()
    require('neorg').setup {
      load = {
        ['core.defaults'] = {},
        ['core.concealer'] = {},
        ['core.dirman'] = {
          config = {
            workspaces = {
              notes = '~/notes',
            },
            default_workspace = 'notes',
          },
        },
      },
    }

    vim.wo.foldlevel = 99
    vim.wo.conceallevel = 2
  end,
}
