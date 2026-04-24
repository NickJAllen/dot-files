local indent_value = 2

local function key(k, command, desc)
  vim.keymap.set('n', k, ':Neorg ' .. command .. '<CR>', { desc = desc, silent = true })
end

return {
  'nvim-neorg/neorg',
  lazy = false,
  version = '*',
  -- enabled = false,
  dependencies = {
    'nvim-neorg/tree-sitter-norg',
    'nvim-neorg/tree-sitter-norg-meta',
    'vhyrro/luarocks.nvim',
  },
  config = function()
    require('neorg').setup {
      load = {
        ['core.defaults'] = {},
        ['core.esupports.indent'] = {
          config = {
            indents = {
              _ = { indent = indent_value },
              heading1 = { indent = 0 * indent_value },
              heading2 = { indent = 1 * indent_value },
              heading3 = { indent = 2 * indent_value },
              heading4 = { indent = 3 * indent_value },
              heading5 = { indent = 4 * indent_value },
              heading6 = { indent = 5 * indent_value },
              paragraph_segment = { indent = indent_value },
              ranged_tag = { indent = indent_value },
              ranged_tag_content = { indent = indent_value },
              strong_paragraph_delimiter = { indent = indent_value },
            },
          },
        },
        ['core.concealer'] = {
          indent_multiline_whitespace = true,
        },
        ['core.dirman'] = {
          config = {
            workspaces = {
              notes = '~/notes',
            },
            default_workspace = 'notes',
          },
        },
      },
    }

    vim.wo.foldlevel = 99
    vim.wo.conceallevel = 2

    key('<leader>ni', 'index', 'Index')
    key('<leader>nr', 'return', 'Return')
    key('<leader>nt', 'toggle-concealer', 'Toggle Concealer')
  end,
}
