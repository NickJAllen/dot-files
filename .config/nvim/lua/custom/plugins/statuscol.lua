return {
  {
    'luukvbaal/statuscol.nvim',
    config = function()
      local builtin = require 'statuscol.builtin'

      require('statuscol').setup {
        -- configuration goes here, for example:
        relculright = true,
        segments = {
          {
            sign = { name = { '.*' }, maxwidth = 2, colwidth = 2, auto = true, wrap = true },
            click = 'v:lua.ScSa',
          },
          { text = { builtin.foldfunc }, click = 'v:lua.ScFa' },
          {
            sign = { namespace = { 'diagnostic/signs' }, maxwidth = 2, auto = true },
            click = 'v:lua.ScSa',
          },
          { text = { builtin.lnumfunc }, click = 'v:lua.ScLa' },
          --padding
          { text = { ' ' }, click = 'v:lua.ScL', hl = 'Normal' },
        },
      }
    end,
  },
}
