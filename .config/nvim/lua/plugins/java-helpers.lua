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
      'JavaHelpersDeobfuscate',
      'JavaHelpersSelectObfuscationFile',
    },

    ---@type JavaHelpers.Config
    opts = {
      ---@type JavaHelpers.NewFileConfig
      new_file = {
        ---Each template has a name and some template source code.
        ---${package_decl} and ${name} will be replaced with the package declaration and name for the Java type being created.
        ---If ${pos} is provided then the cursor will be positioned there ready to type.
        templates = {},

        ---Defines patters to recognize Java source directories in order to determine the package name.
        java_source_dirs = { 'src/main/java', 'src/test/java', 'src' },

        ---If true then newly created Java files will be formatted
        should_format = true,
      },

      ---@type JavaHelpers.StackTraceConfig
      stack_trace = {
        obfuscation_mappings_dir = vim.uv.os_homedir() .. '/.obfuscation',
      },
    },
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
      { '<leader>Jd', ':JavaHelpersDeobfuscate<cr>', desc = 'Deofuscate Java stack trace' },
      { '<leader>JD', ':JavaHelpersDeobfuscate +<cr>', desc = 'Deofuscate Java stack trace on Clipboard' },
      { '<leader>Jo', ':JavaHelpersSelectObfuscationFile<cr>', desc = 'Select obfuscation file' },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',

      -- This is only needed if you want to use the JavaHelpersPickStackTraceLine command (but highly recommended)
      'folke/snacks.nvim',
    },
  },
}
