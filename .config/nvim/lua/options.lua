-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ','

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

vim.g.neovide_input_macos_option_key_is_meta = 'only_left'

vim.g.snacks_animate = true
vim.g.snacks_indent = true

vim.g.editorconfig = true

-- Allow loading directory specific configurations
vim.opt.exrc = true

-- Disable swap file as this was annoying me
vim.opt.swapfile = false

vim.opt.fillchars = {
  foldopen = '',
  foldclose = '',
  fold = ' ',
  foldsep = ' ',
  diff = '╱',
  eob = ' ',
}

vim.opt.background = 'dark'
-- Make line numbers default
vim.o.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
vim.o.relativenumber = true

vim.o.tabstop = 4 -- width of a tab character
vim.o.shiftwidth = 4 -- indentation width
vim.o.expandtab = true -- use spaces instead of tabs
vim.o.softtabstop = 4 -- insert 4 spaces when pressing Tab

-- Enable mouse mode, can be useful for resizing splits for example!
vim.o.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
--
--  Notice listchars is set using `vim.opt` instead of `vim.o`.
--  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
--   See `:help lua-options`
--   and `:help lua-options-guide`
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

-- disable folding on startup
vim.opt.foldenable = false
vim.opt.foldlevel = 1

vim.opt.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'

-- OSC 52 allows copy and pasting with remote client even through tmux.
-- Unfortunately some terminals like WezTerm don't support reading the clipboard for pasting as they consider this a security risk and just hang the process
-- Once WezTerm fixes this and somehow allows it then set this to true.

-- local is_os_paste_supported = true
--
-- local function os_paste_unsupported(register)
--   vim.notify 'OS paste is disabled as some terminals like WezTerm just hang\nUse the OS shortcut to paste from the OS'
--   return { '', '' }
-- end
--
-- local function os_paste(register)
--   if is_os_paste_supported then
--     return require('vim.ui.clipboard.osc52').paste(register)
--   end
--
--   return function()
--     os_paste_unsupported(register)
--   end
-- end
--
-- vim.g.clipboard = {
--   name = 'OSC 52',
--   copy = {
--     ['+'] = require('vim.ui.clipboard.osc52').copy '+',
--     ['*'] = require('vim.ui.clipboard.osc52').copy '*',
--   },
--   paste = {
--     ['+'] = os_paste '+',
--     ['*'] = os_paste '*',
--   },
-- }

-- vim: ts=2 sts=2 sw=2 et
