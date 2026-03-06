local nick = require 'nick'

-- Refresh the state of unmodified buffers when focus is gained
-- Disabled for now as it can be easily invoked explicity when needed.
-- vim.api.nvim_create_autocmd('FocusGained', {
--   callback = function()
--     nick.utils.reload_unmodified_buffers()
--   end,
-- })

-- Save all files after a refactoring completes
vim.api.nvim_create_autocmd('LspRequest', {
  callback = function(args)
    local request = args.data.request
    local request_method = request.method

    if request.type == 'complete' then
      -- do something with finished requests. this pending
      -- request entry is about to be removed since it is complete
      --

      local is_refactoring = (request_method == 'textDocument/rename' or request_method == 'textDocument/codeAction')

      -- print('Finished LSP request ' .. request_method)

      if is_refactoring then
        print 'Finished LSP refactoring'
        vim.schedule(nick.utils.after_refactoring_complete)
      end
    end
  end,
})

-- Make a snapshot in jj after any files are written to disk
vim.api.nvim_create_autocmd('BufWritePost', {
  callback = function(args)
    local buf = args.buf

    if vim.bo[buf].buftype ~= '' then
      return -- skip virtual/scratch/terminal buffers
    end

    nick.utils.jj_snapshot()
  end,
})

local last_sent_tmux_pane_dir = ''

local function set_tmux_pane_directory(directory)
  if #directory == 0 or not vim.loop.fs_stat(directory) then
    return
  end

  if directory == last_sent_tmux_pane_dir then
    return
  end

  last_sent_tmux_pane_dir = directory

  -- print('setting tmux nvim path to ' .. directory)
  vim.fn.jobstart { 'tmux', 'set-option', '-p', '@neovim_path', directory }
end

local function update_tmux_pane_directory()
  local buftype = vim.bo.buftype
  local path = vim.api.nvim_buf_get_name(0)

  if #path == 0 then
    return
  end

  local is_normal_buffer = buftype == ''

  if not is_normal_buffer then
    return
  end

  local dir = vim.fs.dirname(vim.fs.abspath(path))

  set_tmux_pane_directory(dir)
end

if vim.env.TMUX then
  vim.api.nvim_create_autocmd({ 'BufEnter', 'DirChanged' }, {
    group = vim.api.nvim_create_augroup('TmuxPaneDirUpdate', { clear = true }),
    callback = update_tmux_pane_directory,
  })
end
