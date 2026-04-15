return {
  'ember-theme/nvim',
  name = 'ember',
  priority = 1000,
  config = function()
    require('ember').setup {
      variant = 'ember', -- "ember" | "ember-soft" | "ember-light"
    }
    vim.cmd 'colorscheme ember'
  end,
}
