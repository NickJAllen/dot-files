local M = {}
-- Create a unique namespace for the extmarks to avoid conflicts
local ns_id = vim.api.nvim_create_namespace 'HgAnnotate'
-- Assuming plenary.log is available for better messages
local log = require('plenary.log').new { plugin = 'hg-annotate', level = 'info' }

-- Globals for state management
-- cache stores { [bufnr] = { [line_num] = {rev, user}, ... } }
local cache = {}
local augroup_name = 'HgAnnotateGroup'
-- Create a new augroup specifically for the CursorMoved autocommand
local augroup_id = vim.api.nvim_create_augroup(augroup_name, { clear = true })
local float_win_id = nil -- ID of the floating window showing the commit message

-- Helper to clear the floating window
local function close_float()
  if float_win_id and vim.api.nvim_win_is_valid(float_win_id) then
    -- Close the window and delete the associated scratch buffer
    local float_buf_id = vim.api.nvim_win_get_buf(float_win_id)
    vim.api.nvim_win_close(float_win_id, true)
    if vim.api.nvim_buf_is_loaded(float_buf_id) then
      vim.api.nvim_buf_delete(float_buf_id, {})
    end
  end
  float_win_id = nil
end

-- Helper to clean up all blame remnants for a buffer
local function clear_blame(buf)
  if not buf then
    buf = vim.api.nvim_get_current_buf()
  end

  -- Clear margin annotations
  vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)

  -- Remove cache entry
  cache[buf] = nil

  -- Close floating window
  close_float()

  log.info('Cleared Hg annotations for buffer: ' .. buf)
end

-- Function to run the costly HG command once and cache results (rev and user only)
local function run_and_cache_blame(filepath)
  local buf = vim.api.nvim_get_current_buf()
  -- Command to run: -n (revision number), -u (user)
  local cmd = { 'hg', 'annotate', '-T', "{lines % '{rev},{user}\n'}", filepath }
  log.info('Caching full blame: ' .. table.concat(cmd, ' '))

  -- WARNING: SYNCHRONOUS
  local output = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    log.error "hg annotate failed. Is 'hg' installed and is this a Mercurial repo?"
    return nil
  end

  local lines = vim.split(output, '\n', {})
  local annotations = {}

  for i, line in ipairs(lines) do
    -- Line format: "1234: user: The file content..."
    -- Use limit=3 to ensure content containing ':' doesn't break parsing
    local parts = vim.split(line, ',', { plain = true, trimempty = true, limit = 3 })
    if #parts >= 2 then
      annotations[i] = {
        rev = parts[1],
        user = parts[2],
      }
    end
  end

  cache[buf] = annotations
  return annotations
end

-- Runs on CursorMoved
local function update_blame_at_cursor()
  local buf = vim.api.nvim_get_current_buf()

  -- Safety check: ensure we are tracking this buffer
  if not cache[buf] then
    return
  end

  -- Get current 1-indexed line number
  local lnum = vim.api.nvim_win_get_cursor(0)[1]

  -- Line data is 1-indexed (lua table)
  local line_data = cache[buf][lnum]

  -- 1. Clear previous line's marginal V-Text and floating window
  vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)
  close_float()

  if not line_data then
    log.debug('No blame data for line ' .. lnum)
    return
  end

  local rev = line_data.rev
  local user = line_data.user

  -- --- 1. Margin Blame (Rev and User - only on current line) ---
  local virt_text = {
    { '[' .. rev .. ']', 'HgAnnotateRev' }, -- Highlight group for rev
    { ' ' .. user, 'HgAnnotateUser' }, -- Highlight group for user
  }

  -- Add virtual text to the current line (lnum - 1 is 0-indexed line)
  vim.api.nvim_buf_set_extmark(buf, ns_id, lnum - 1, 0, {
    virt_text = virt_text,
    virt_text_pos = 'overlay', -- Left margin
  })

  -- --- 2. Message Blame (Floating Window) ---

  -- Get commit message (Synchronous call to hg log - this is the slow part)
  local log_cmd = { 'hg', 'log', '-r', rev, '--template', '{desc}' }
  local message_raw = vim.fn.system(log_cmd)

  if vim.v.shell_error ~= 0 then
    log.error('hg log failed for revision ' .. rev)
    return
  end

  local message_lines = vim.split(message_raw, '\n', {})
  local message = {}
  -- Clean up leading/trailing whitespace and empty lines
  for _, line in ipairs(message_lines) do
    local trimmed_line = line:match '^%s*(.-)%s*$'
    if trimmed_line and trimmed_line ~= '' then
      table.insert(message, trimmed_line)
    end
  end

  local message_text = table.concat(message, '\n')
  if #message_text == 0 then
    message_text = 'No commit message found.'
  end

  -- Prepare the buffer for the floating window
  local float_buf = vim.api.nvim_create_buf(false, true) -- Not listed, scratch

  -- Add title (rev and author) and message
  local float_content = {
    'Commit: ' .. rev .. ' by ' .. user,
    '-----------------------------------------',
    message_text,
  }

  vim.api.nvim_buf_set_lines(float_buf, 0, -1, false, float_content)

  -- Calculate window size and position
  local win_height = math.min(#float_content, 10) + 2 -- Max 10 lines + header/separator
  local win_width = 80 -- Fixed width for message legibility

  -- Get current window dimensions and cursor position
  local win_info = vim.api.nvim_win_get_config(0)
  local current_cursor_row = vim.api.nvim_win_get_cursor(0)[1] - 1 -- 0-indexed row

  -- Position below the cursor line
  local row = current_cursor_row + 1
  local col = 0

  -- Ensure window does not go off the bottom of the screen
  -- win_info.height gives the actual height of the Neovim window (not screen)
  if row + win_height > win_info.height then
    -- If it would overflow, place it above the cursor line
    row = current_cursor_row - win_height
  end
  -- Clamp to the top edge
  if row < 0 then
    row = 0
  end

  -- Open the floating window
  float_win_id = vim.api.nvim_open_win(float_buf, true, {
    relative = 'win',
    row = row,
    col = col,
    width = win_width,
    height = win_height,
    style = 'minimal',
    border = 'single',
    focusable = false, -- Don't steal focus
  })

  -- Highlight the header/rev line in the float window
  vim.api.nvim_buf_add_highlight(float_buf, ns_id, 'Title', 0, 0, -1)
end

--- Toggles the visibility and tracking of Hg Annotate.
function M.toggle_annotations()
  local buf = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(buf)

  if cache[buf] then
    -- Annotation is ON -> Turn OFF
    -- Clear the autocommand specific to this buffer
    vim.api.nvim_clear_autocmds { group = augroup_name, buffer = buf }
    clear_blame(buf)
    vim.notify('Hg Annotate: OFF', vim.log.levels.INFO)
  else
    -- Annotation is OFF -> Turn ON
    -- Check if file is valid
    if filepath == '' or not vim.fn.isdirectory(vim.fn.fnamemodify(filepath, ':h')) then
      vim.notify('Hg Annotate: Not a valid file or Mercurial repo.', vim.log.levels.WARN)
      return
    end

    local annotations = run_and_cache_blame(filepath)
    if annotations then
      -- Setup autocommand to update blame on cursor movement
      vim.api.nvim_create_autocmd('CursorMoved', {
        group = augroup_id,
        buffer = buf,
        callback = update_blame_at_cursor,
        desc = 'Update Hg blame text on cursor move',
      })

      -- Run immediately on toggle
      update_blame_at_cursor()
      vim.notify('Hg Annotate: ON (Tracking current line)', vim.log.levels.INFO)
    end
  end
end

-- Define the highlight groups needed for the virtual text appearance and floating window
vim.cmd [[highlight default link HgAnnotateRev String]]
vim.cmd [[highlight default link HgAnnotateUser Identifier]]
vim.cmd [[highlight default link HgAnnotateText Comment]]
vim.cmd [[highlight default link Title Normal]]

return M
