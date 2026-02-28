-- Better quickfix list workflow
return {
  'stevearc/quicker.nvim',
  ft = 'qf',
  ---@module "quicker"
  ---@type quicker.SetupOptions
  opts = {},
  config = function()
    require('quicker').setup {
      keys = {
        {
          '>',
          function()
            require('quicker').expand { before = 2, after = 2, add_to_existing = true }
          end,
          desc = 'Expand quickfix context',
        },
        {
          '<',
          function()
            require('quicker').collapse()
          end,
          desc = 'Collapse quickfix context',
        },
      },
    }
  end,
  keys = {
    {
      '<leader>tQ',
      function()
        require('quicker').toggle()
      end,
      desc = 'Toggle Quickfix list (Quicker)',
    },
  },
}
