return {
  {
    'NickJAllen/java-helpers.nvim',
    dev = true,
    cmd = { 'JavaHelpersNewFile', 'JavaHelpersGoToStackTrace' },
    opts = {},
    keys = {
      { '<leader>Jn', ':JavaHelpersNewFile<cr>', desc = 'New Java Type' },
      { '<leader>Jc', ':JavaHelpersNewFile Class<cr>', desc = 'New Java Class' },
      { '<leader>Ji', ':JavaHelpersNewFile Interface<cr>', desc = 'New Java Interface' },
      { '<leader>Ja', ':JavaHelpersNewFile Abstract Class<cr>', desc = 'New Abstract Java Class' },
      { '<leader>Jr', ':JavaHelpersNewFile Record<cr>', desc = 'New Java Record' },
      { '<leader>Je', ':JavaHelpersNewFile Enum<cr>', desc = 'New Java Enum' },
      { '<leader>Js', ':JavaHelpersGoToStackTrace<cr>', desc = 'Go to Java stack trace line' },
    },
    dependencies = {
      { 'nvim-lua/plenary.nvim' },
    },
  },
}
