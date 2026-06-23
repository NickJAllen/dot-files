return {
  'ember-theme/nvim',
  name = 'ember',
  lazy = true,
  priority = 1000,
  config = function()
    require('ember').setup {
      variant = 'ember', -- "ember" | "ember-soft" | "ember-light"
    }
  end,
}
