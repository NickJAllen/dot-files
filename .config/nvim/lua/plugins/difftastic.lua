return {
  'clabby/difftastic.nvim',
  dependencies = {
    'MunifTanjim/nui.nvim',
    -- optional: only needed for :DifftPick
    'folke/snacks.nvim',
  },
  config = function()
    require('difftastic-nvim').setup {
      download = true, -- Auto-download pre-built binary
      snacks_picker = {
        enabled = true,
      },
    }
  end,
}
