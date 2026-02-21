-- Save in insert mode with Ctrl-S
vim.keymap.set('i', '<C-s>', '<Esc>:write<CR>l')

-- Save in normal mode with Ctrl-S
vim.keymap.set('n', '<C-s>', ':write<CR>')

-- Save all with Ctrl-Shift-S
vim.keymap.set('n', '<C-S-S>', ':wall<CR>')

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Move using h, l with Ctrl modifier in insert mode
vim.keymap.set('i', '<C-h>', '<Left>')
vim.keymap.set('i', '<C-l>', '<Right>')

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.keymap.set({ 'n', 'x' }, '<leader>y', '"+y', { desc = 'Copy to system clipboard' })
vim.keymap.set({ 'n', 'x' }, '<leader>Y', '"+yg_', { desc = 'Copy line to system clipboard' })
vim.keymap.set({ 'n', 'x' }, '<leader>p', '"+p', { desc = 'Paste from system clipboard' })
vim.keymap.set({ 'n', 'x' }, '<leader>P', '"+P', { desc = 'Paste before from system clipboard' })

local nick = require 'nick'

-- Buffer management

vim.keymap.set('n', '<leader>bb', ':buffer #<CR>', { desc = 'Back To Previous Buffer' })
vim.keymap.set('n', '<leader>bq', nick.utils.delete_current_buffer, { desc = 'Close Buffer' })
vim.keymap.set('n', '<leader>bd', nick.utils.delete_current_buffer_and_file, { desc = 'Delete Buffer and File' })
vim.keymap.set('n', '<leader>bn', ':enew<CR>', { desc = 'New Buffer' })
vim.keymap.set('n', '<leader>bo', nick.utils.delete_other_unmodified_buffers, { desc = 'Close Other Unmodified Buffers' })
vim.keymap.set('n', '<leader>bm', nick.utils.open_messages, { desc = 'Open Messages' })
vim.keymap.set('n', '<leader>br', nick.utils.reload_unmodified_buffers, { desc = 'Reload Unmodified Buffers' })

vim.keymap.set('n', '<leader>s.', nick.utils.open_directory_in_oil, { desc = 'Open directory in Oil' }) -- vim: ts=2 sts=2 sw=2 et

vim.keymap.set('n', '[e', function()
  vim.diagnostic.goto_prev {
    severity = vim.diagnostic.severity.ERROR,
  }
end, { desc = 'Go to previous diagnostic error' }) -- Automated tasks

vim.keymap.set('n', ']e', function()
  vim.diagnostic.goto_next {
    severity = vim.diagnostic.severity.ERROR,
  }
end, { desc = 'Go to next diagnostic error' })

vim.api.nvim_create_user_command('QuickfixItemDo', function(opts)
  if opts.args == '' then
    nick.utils.quickfix_item_do()
  else
    nick.utils.quickfix_item_do_command(opts.args)
  end
end, { nargs = '?' })

vim.keymap.set('n', '<leader>Aqi', nick.utils.quickfix_item_do, { desc = 'Run command on each item in the quickfix list' })

vim.keymap.set('n', '<leader>Aqf', function()
  local command = vim.fn.input 'Enter command to run on each file in the quickfix list'
  nick.utils.quickfix_file_do(command)
end, { desc = 'Run command on each file in the quickfix list' })

vim.keymap.set('n', '<leader>Ac', function()
  nick.utils.cancel_actions()
end, { desc = 'Cancel automated actions' })

-- Utilities

vim.keymap.set('n', '<leader>ur', nick.utils.choose_random_colorscheme, { desc = 'Choose Random Colorscheme' })
vim.keymap.set('n', '<leader>ul', ':Lazy<CR>', { desc = 'Show Lazy Plug-in Manager' })
vim.keymap.set('n', '<leader>um', ':Mason<CR>', { desc = 'Show Lazy Plug-in Manager' })

-- Mercurial

vim.keymap.set('n', '<leader>ma', nick.mercurial.toggle_annotations, { desc = 'Toggle mercurial annotations' })
