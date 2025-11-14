-- Makes it easier to manage global marks by assigning the A-Z mark name automatically
-- and allowing navigation through the global marks (next and prev)
return {
  {
    'fnune/recall.nvim',
    config = function()
      local recall = require 'recall'

      recall.setup {
        sign = '',
        sign_highlight = '@comment.note',

        telescope = {
          autoload = true,
          mappings = {
            unmark_selected_entry = {
              normal = 'dd',
              insert = '<M-d>',
            },
          },
        },

        wshada = vim.fn.has 'nvim-0.10' == 0,
      }

      vim.keymap.set('n', 'mm', recall.toggle, { noremap = true, silent = true, desc = 'Toggle Mark' })
      vim.keymap.set('n', 'mn', recall.goto_next, { noremap = true, silent = true, desc = 'Next Mark' })
      vim.keymap.set('n', 'mp', recall.goto_prev, { noremap = true, silent = true, desc = 'Previous Mark' })
      vim.keymap.set('n', 'mc', recall.clear, { noremap = true, silent = true, desc = 'Clear Marks' })
      vim.keymap.set('n', 'ml', require('recall.snacks').pick, { noremap = true, silent = true, desc = 'List Marks' })
    end,
  },
}
