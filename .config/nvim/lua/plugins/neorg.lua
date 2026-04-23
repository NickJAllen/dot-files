return {
  'nvim-neorg/neorg',
  lazy = false,
  version = '*',
  -- enabled = false,
  dependencies = {
    'nvim-neorg/tree-sitter-norg',
    'nvim-neorg/tree-sitter-norg-meta',
    'vhyrro/luarocks.nvim',
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

    vim.keymap.set('n', '<leader>ni', ':Neorg index<CR>', { desc = 'Neorg Index', silent = true })
    vim.keymap.set('n', '<leader>nr', ':Neorg return<CR>', { desc = 'Neorg Return', silent = true })
  end,
}
