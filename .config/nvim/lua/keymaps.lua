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

vim.keymap.set('n', '<leader>qd', nick.utils.deduplicate_qf, { desc = 'Remove duplicate entries from quickfix list' })

-- Utilities
--

local started_verbose_debugging = false

vim.keymap.set('n', '<leader>Ur', nick.utils.choose_random_colorscheme, { desc = 'Choose Random Colorscheme' })
vim.keymap.set('n', '<leader>Ul', ':Lazy<CR>', { desc = 'Show Lazy Plug-in Manager' })
vim.keymap.set('n', '<leader>Um', ':Mason<CR>', { desc = 'Show Mason' })
vim.keymap.set('x', '<leader>Us', ':CodeSnap<CR>', { desc = 'Copy code snapshot to clipboard' })
vim.keymap.set('n', '<leader>Ug', function()
  local before = collectgarbage 'count'
  collectgarbage 'collect'
  local after = collectgarbage 'count'
  print(string.format('Manual GC: %.2fKB -> %.2fKB', before, after))
end, { desc = 'Perform GC' })
vim.keymap.set('n', '<leader>Up', function()
  Snacks.profiler.toggle()
end, { desc = 'Toggle Snacks Profiler' })

-- Can be useful when getting infinite loops in lua code to see what is happenning
vim.keymap.set('n', '<leader>Uv', function()
  if not started_verbose_debugging then
    started_verbose_debugging = true
    local name = '/tmp/neovim-jit-debug.log'
    require('jit.v').start(name)
    vim.notify('Started JIT debug logging to ' .. name)
  end
end, { desc = 'Start JIT Debug log' })

local periodic_stack_dump_file_path = '/tmp/nvim-' .. vim.fn.getpid() .. '-stack-dumps.txt'
---@type file*?
local periodic_stack_dump_file = nil
local has_added_thread_dump_hook = false

local function on_periodic_stack_dump()
  if not periodic_stack_dump_file then
    periodic_stack_dump_file = io.open(periodic_stack_dump_file_path, 'a')
  end

  local f = periodic_stack_dump_file

  if f then
    f:write('\n--- TRACEBACK: ' .. os.date '%Y-%m-%d %H:%M:%S' .. ' ---\n')
    f:write(debug.traceback() .. '\n')
    f:flush(f)
  end
end

local function start_dumping_stack_periodically()
  if has_added_thread_dump_hook then
    return
  end

  debug.sethook(on_periodic_stack_dump, '', 1000000)
  vim.notify('Dumping periodic stack traces to ' .. periodic_stack_dump_file_path)
  has_added_thread_dump_hook = true
end

local function stop_dumping_stack_periodically()
  if not has_added_thread_dump_hook then
    return
  end

  debug.sethook()

  if periodic_stack_dump_file then
    periodic_stack_dump_file:close()
    periodic_stack_dump_file = nil
  end

  has_added_thread_dump_hook = false
  vim.notify('Stopped dumping periodic stack traces to ' .. periodic_stack_dump_file_path)
end

local function toggle_dumping_stack_periodically()
  if has_added_thread_dump_hook then
    stop_dumping_stack_periodically()
  else
    start_dumping_stack_periodically()
  end
end

vim.schedule(start_dumping_stack_periodically)

--- Dump stack every after a number of instructions (useful to debug inifinite loops)
vim.keymap.set('n', '<leader>Ud', toggle_dumping_stack_periodically, { desc = 'Toggle dumping of stack trace every so often' })

-- Mercurial

vim.keymap.set('n', '<leader>ma', nick.mercurial.toggle_annotations, { desc = 'Toggle mercurial annotations' })
