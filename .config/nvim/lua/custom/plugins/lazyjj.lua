return {
  {
    'swaits/lazyjj.nvim',
    dependencies = 'nvim-lua/plenary.nvim',
    cmd = 'LazyJJ',
    keys = {
      { '<leader>vj', ':LazyJJ<cr>', desc = 'Show lazyjj' },
    },
    opts = {},
  },
}
