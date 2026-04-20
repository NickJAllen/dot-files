local function key(k, action, desc)
  return { k, ':Automator ' .. action .. '<CR>', { desc = desc, silent = true } }
end

return {
  'NickJAllen/automator.nvim',
  dev = true,
  cmd = { 'Automator' },
  opts = {},
  keys = {
    key('<leader>At', 'toggle', 'Toggle Automator UI'),
    key('<leader>Aa', 'apply', 'Apply fix'),
    key('<leader>AA', 'apply_all', 'Apply fix to all'),
    key('<leader>Ad', 'diagnostics', 'Import diagnostics'),
    key('<leader>Ae', 'errors', 'Import errors'),
    key('<leader>Aw', 'warnings', 'Import warnings'),
    key('<leader>Ai', 'infos', 'Import infos'),
    key('<leader>An', 'next', 'Next location to fix'),
    key('<leader>Ap', 'prev', 'Prev location to fix'),
    key('<leader>Aq', 'quickfix', 'Import quickfix list'),
    key('<leader>Af', 'toggle_file_mode', 'Toggle file mode'),
    key('<leader>Ac', 'insert_code_action', 'Insert Code Action'),
    key('<leader>As', 'stop', 'Stop'),
    key('<leader>se', 'pick errors', 'Workspace errors'),
    key('<leader>sw', 'pick warnings', 'Workspace warnings'),
    key('<leader>sd', 'pick diagnostics', 'Workspace diagnostics'),
    key('<leader>sD', 'pick file-diagnostics', 'File diagnostics'),
    key('<leader>sE', 'pick file-errors', 'File errors'),
    key('<leader>sW', 'pick file-warnings', 'File warnings'),
    key('<leader>sq', 'pick quickfix', 'Quickfix list'),
    key('<leader>sQ', 'pick file-quickfix', 'File Quickfix list'),
    key('<leader>sr', 'resume_pick', 'Resume pick'),
  },
}
