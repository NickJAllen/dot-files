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
