-- A behind the scene global marks manager for Neovim. Marko saves and restores your global marks for each project directory, so they persist across Neovim sessions and are properly isolated between projects.
return {
  'mohseenrm/marko.nvim',
  config = function()
    require('marko').setup()
  end,
}
