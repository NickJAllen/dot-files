local function key(k, action, desc)
  return { '<leader>n' .. k, ':Obsidian ' .. action .. '<CR>', desc = desc }
end

return {
  'obsidian-nvim/obsidian.nvim',
  version = '*', -- use latest release, remove to use latest commit
  ---@module 'obsidian'
  ---@type obsidian.config
  opts = {
    legacy_commands = false, -- this will be removed in 4.0.0
    workspaces = {
      {
        name = 'personal',
        path = '~/obsidian/personal',
      },
      {
        name = 'work',
        path = '~/obsidian/work',
      },
    },
  },
  cmd = 'Obsidian',
  keys = {
    key('n', 'new', 'New note'),
    key('s', 'search', 'Search for note'),
    key('t', 'tags', 'Tags'),
    key('w', 'workspace', 'Select workspace'),
  },
}
