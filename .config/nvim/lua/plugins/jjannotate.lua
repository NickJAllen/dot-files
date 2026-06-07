return {
  'https://tangled.org/ronshavit.com/jjannotate.nvim',
  keys = {
    {
      '<leader>ja',
      function()
        require('jjannotate').toggle()
      end,
      desc = 'Annotate',
    },
  },
}
