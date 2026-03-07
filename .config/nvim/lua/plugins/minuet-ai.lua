return {
  'milanglacier/minuet-ai.nvim',
  config = function()
    require('minuet').setup {
      provider = 'gemini',
      provider_options = {
        gemini = {
          model = 'gemini-2.5-flash',
          optional = {
            generationConfig = {
              maxOutputTokens = 256,
            },
          },
        },
      },
      virtualtext = {
        -- auto_trigger_ft = { '*' },
        auto_trigger_ft = {},
        keymap = {
          accept = '<A-A>',
          accept_line = '<A-a>',
          prev = '<A-[>',
          next = '<A-]>',
          dismiss = '<A-e>',
        },
      },
    }
  end,
}
