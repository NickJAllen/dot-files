return {
  {
    'folke/trouble.nvim',
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = 'Trouble',
    keys = {
      {
        '<leader>td',
        '<cmd>Trouble diagnostics toggle<cr>',
        desc = 'Toggle Diagnostics (Trouble)',
      },
      {
        '<leader>tD',
        '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
        desc = 'Toggle Buffer Diagnostics (Trouble)',
      },
      {
        '<leader>to',
        '<cmd>Trouble symbols toggle focus=false<cr>',
        desc = 'Toggle Outline (Trouble)',
      },
      {
        '<leader>tr',
        '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
        desc = 'Toggle References (Trouble)',
      },
      {
        '<leader>tl',
        '<cmd>Trouble loclist toggle<cr>',
        desc = 'Toggle Location List (Trouble)',
      },
      {
        '<leader>tq',
        '<cmd>Trouble qflist toggle<cr>',
        desc = 'Toggle Quickfix List (Trouble)',
      },
      {
        '<leader>tt',
        '<cmd>Trouble todo toggle<cr>',
        desc = 'Toggle Todo List (Trouble)',
      },
    },
  },
}
