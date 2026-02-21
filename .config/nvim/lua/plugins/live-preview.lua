return {
  'brianhuster/live-preview.nvim',
  dependencies = {
    -- You can choose one of the following pickers
    -- 'nvim-telescope/telescope.nvim',
    -- 'ibhagwan/fzf-lua',
    -- 'echasnovski/mini.pick',
    'folke/snacks.nvim',
  },
  keys = {
    { '<leader>up', ':LivePreview start<CR>', desc = 'Start live preview in browser' },
  },
}
