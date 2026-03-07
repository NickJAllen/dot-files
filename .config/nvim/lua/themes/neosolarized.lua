return {
  'svrana/neosolarized.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    require('neosolarized').setup {
      comment_italics = true,
      background_set = false,
    }
  end,
  dependencies = {
    'tjdevries/colorbuddy.nvim',
  },
}
