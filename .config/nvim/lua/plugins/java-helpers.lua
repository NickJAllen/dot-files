return {
  {
    'NickJAllen/java-helpers.nvim',
    -- dev = true,
    cmd = {
      'JavaHelpersNewFile',
      'JavaHelpersGoToStackTraceLine',
      'JavaHelpersGoUpStackTrace',
      'JavaHelpersGoDownStackTrace',
      'JavaHelpersGoToBottomOfStackTrace',
      'JavaHelpersGoToTopOfStackTrace',
    },
    opts = {},
    keys = {
      { '<leader>Jn', ':JavaHelpersNewFile<cr>', desc = 'New Java Type' },
      { '<leader>Jc', ':JavaHelpersNewFile Class<cr>', desc = 'New Java Class' },
      { '<leader>Ji', ':JavaHelpersNewFile Interface<cr>', desc = 'New Java Interface' },
      { '<leader>Ja', ':JavaHelpersNewFile Abstract Class<cr>', desc = 'New Abstract Java Class' },
      { '<leader>Jr', ':JavaHelpersNewFile Record<cr>', desc = 'New Java Record' },
      { '<leader>Je', ':JavaHelpersNewFile Enum<cr>', desc = 'New Java Enum' },
      { '<leader>Js', ':JavaHelpersGoToStackTraceLine<cr>', desc = 'Go to Java stack trace line' },
      { '[j', ':JavaHelpersGoUpStackTrace<cr>', desc = 'Go up Java stack trace' },
      { ']j', ':JavaHelpersGoDownStackTrace<cr>', desc = 'Go down Java stack trace' },
      { '<leader>[j', ':JavaHelpersGoToTopOfStackTrace<cr>', desc = 'Go to top of Java stack trace' },
      { '<leader>]j', ':JavaHelpersGoToBottomOfStackTrace<cr>', desc = 'Go to bottom of Java stack trace' },
    },
    dependencies = {
      { 'nvim-lua/plenary.nvim' },
    },
  },
}
