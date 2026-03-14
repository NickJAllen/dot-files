return {
  'NickJAllen/automator.nvim',
  dev = true,
  cmd = { 'Automator' },
  opts = {},
  keys = {
    { '<leader>At', ':Automator toggle<CR>', desc = 'Toggle Automator UI' },
    { '<leader>Aa', ':Automator apply<CR>', desc = 'Apply fix' },
    { '<leader>AA', ':Automator apply_all<CR>', desc = 'Apply fix to all' },
    { '<leader>Ad', ':Automator diagnostics<CR>', desc = 'Import diagnostics' },
    { '<leader>Aq', ':Automator quickfix<CR>', desc = 'Import quickfix list' },
    { '<leader>Af', ':Automator toggle_file_mode<CR>', desc = 'Toggle file mode' },
    { '<leader>Ac', ':Automator insert_code_action<CR>', desc = 'Insert Code Action' },
  },
}
