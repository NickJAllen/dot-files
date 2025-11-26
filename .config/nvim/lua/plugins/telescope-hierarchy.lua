return {
  'jmacadie/telescope-hierarchy.nvim',
  -- branch = 'feature/types',
  dependencies = {
    {
      'nvim-telescope/telescope.nvim',
      dependencies = { 'nvim-lua/plenary.nvim' },
    },
  },
  keys = {
    { -- lazy style key map
      -- Choose your own keys, this works for me
      '<leader>sc',
      '<cmd>Telescope hierarchy incoming_calls<cr>',
      desc = 'LSP: [S]earch [I]ncoming Calls',
    },
    {
      '<leader>sC',
      '<cmd>Telescope hierarchy outgoing_calls<cr>',
      desc = 'LSP: [S]earch outgoing [C]alls',
    },
  },
  opts = {
    -- don't use `defaults = { }` here, do this in the main telescope spec
    extensions = {
      hierarchy = {
        -- telescope-hierarchy.nvim config, see below
      },
      -- no other extensions here, they can have their own spec too
    },
  },
  config = function(_, opts)
    -- Calling telescope's setup from multiple specs does not hurt, it will happily merge the
    -- configs for us. We won't use data, as everything is in it's own namespace (telescope
    -- defaults, as well as each extension).
    require('telescope').setup(opts)
    require('telescope').load_extension 'hierarchy'
  end,
}
