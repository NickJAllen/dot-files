-- Better folding based on tree sitter that looks much nicer than normal foldns
return {
  {
    'kevinhwang91/nvim-ufo',
    dependencies = 'kevinhwang91/promise-async',
    config = function()
      local ufo = require 'ufo'

      -- Tree-sitter based folding
      vim.o.foldcolumn = '1' -- show fold column
      vim.o.foldlevel = 99 -- start unfolded
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
      vim.o.foldmethod = 'expr'
      vim.o.foldexpr = 'nvim_treesitter#foldexpr()'

      -- Use ufo for fold provider
      ufo.setup()

      -- Optional: keymaps for convenience
      vim.keymap.set('n', 'zM', ufo.closeAllFolds, { desc = 'Close all folds' })
      vim.keymap.set('n', 'zR', ufo.openAllFolds, { desc = 'Open all folds' })
    end,
  },
}
