return {
  'anuvyklack/windows.nvim',
  dependencies = {
    'anuvyklack/middleclass',
    'anuvyklack/animation.nvim',
  },
  config = function()
    vim.o.winwidth = 10
    vim.o.winminwidth = 10
    vim.o.equalalways = false
    require('windows').setup()
  end,
  keys = {
    {
      '<C-w>z',
      ':WindowsMaximize<CR>',
      desc = 'Maximize Window',
    },
    {
      '<C-w>|',
      ':WindowsMaximizeHorizontally<CR>',
      desc = 'Maximize Window Horizontally',
    },
    {
      '<C-w>_',
      ':WindowsMaximizeVertically<CR>',
      desc = 'Maximize Window Vertically',
    },
    {
      '<C-w>=',
      ':WindowsEqualize<CR>',
      desc = 'Equalize Window Size',
    },
  },
}
