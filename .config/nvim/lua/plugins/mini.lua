return {
  { -- Collection of various small independent plugins/modules
    'nvim-mini/mini.nvim',
    lazy = false,
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      require('mini.test').setup()

      require('mini.files').setup {
        mappings = {
          -- go_in = '<CR>',
        },
      }

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
    keys = {
      {
        '<leader>f',
        function()
          MiniFiles.open(vim.api.nvim_buf_get_name(0))
        end,
        desc = 'Open mini file explorer',
      },
      {
        '<leader>F',
        function()
          MiniFiles.open()
        end,
        desc = 'Open mini file explorer in project root',
      },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
