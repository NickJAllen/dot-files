return {
  {
    'NickJAllen/java-helpers.nvim',
    dev = true,
    cmd = {
      'JavaHelpersNewFile',
      'JavaHelpersPickStackTraceLine',
      'JavaHelpersGoToStackTraceLine',
      'JavaHelpersGoUpStackTrace',
      'JavaHelpersGoDownStackTrace',
      'JavaHelpersGoToBottomOfStackTrace',
      'JavaHelpersGoToTopOfStackTrace',
      'JavaHelpersSendStackTraceToQuickfix',
      'JavaHelpersSetObfuscationFile',
    },
    opts = {},
    keys = {
      -- New file creation
      { '<leader>Jn', ':JavaHelpersNewFile<cr>', desc = 'New Java Type' },
      { '<leader>Jc', ':JavaHelpersNewFile Class<cr>', desc = 'New Java Class' },
      { '<leader>Ji', ':JavaHelpersNewFile Interface<cr>', desc = 'New Java Interface' },
      { '<leader>Ja', ':JavaHelpersNewFile Abstract Class<cr>', desc = 'New Abstract Java Class' },
      { '<leader>Jr', ':JavaHelpersNewFile Record<cr>', desc = 'New Java Record' },
      { '<leader>Je', ':JavaHelpersNewFile Enum<cr>', desc = 'New Java Enum' },

      -- Stack trace navigation
      { '<leader>Jg', ':JavaHelpersGoToStackTraceLine<cr>', desc = 'Go to Java stack trace line' },
      { '<leader>JG', ':JavaHelpersGoToStackTraceLine +<cr>', desc = 'Go to Java stack trace line on Clipboard' },
      { '<leader>Jp', ':JavaHelpersPickStackTraceLine<cr>', desc = 'Pick Java stack trace line' },
      { '<leader>JP', ':JavaHelpersPickStackTraceLine +<cr>', desc = 'Pick Java stack trace line from Clipboard' },
      { '[j', ':JavaHelpersGoUpStackTrace<cr>', desc = 'Go up Java stack trace' },
      { ']j', ':JavaHelpersGoDownStackTrace<cr>', desc = 'Go down Java stack trace' },
      { '<leader>Jt', ':JavaHelpersGoToTopOfStackTrace<cr>', desc = 'Go to top of Java stack trace' },
      { '<leader>Jb', ':JavaHelpersGoToBottomOfStackTrace<cr>', desc = 'Go to bottom of Java stack trace' },
      { '<leader>Jq', ':JavaHelpersSendStackTraceToQuickfix<cr>', desc = 'Send Java stack trace to quickfix list' },
      { '<leader>Jo', ':JavaHelpersSetObfuscationFile<cr>', desc = 'Set obfuscation mapping file' },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',

      -- This is only needed if you want to use the JavaHelpersPickStackTraceLine command (but highly recommended)
      'folke/snacks.nvim',
    },
  },
}
