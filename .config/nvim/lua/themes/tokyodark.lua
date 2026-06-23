return {
  {
    'tiagovla/tokyodark.nvim',
    lazy = true,
    opts = {
      -- custom options here
    },
    config = function(_, opts)
      require('tokyodark').setup(opts) -- calling setup is optional
    end,
  },
}
