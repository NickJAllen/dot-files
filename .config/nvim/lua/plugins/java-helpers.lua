return {
  {
    'NickJAllen/java-helpers.nvim',
    -- dev = true,
    cmd = 'JavaHelpersNewFile',
    opts = {},
    keys = {
      { '<leader>jn', ':JavaHelpersNewFile<cr>', desc = 'New Java Type' },
      { '<leader>jc', ':JavaHelpersNewFile Class<cr>', desc = 'New Java Class' },
      { '<leader>ji', ':JavaHelpersNewFile Interface<cr>', desc = 'New Java Interface' },
      { '<leader>ja', ':JavaHelpersNewFile Abstract Class<cr>', desc = 'New Abstract Java Class' },
      { '<leader>jr', ':JavaHelpersNewFile Record<cr>', desc = 'New Java Record' },
      { '<leader>je', ':JavaHelpersNewFile Enum<cr>', desc = 'New Java Enum' },
    },
    dependencies = {
      { 'nvim-lua/plenary.nvim' },
    },
  },
}
