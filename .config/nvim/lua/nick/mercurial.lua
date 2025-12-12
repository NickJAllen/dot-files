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

---@param user string
local function user_name_without_email(user)
  local email_start = user:find ' <'

  if not email_start or email_start < 3 then
    return user
  end

  return user:sub(1, email_start - 1)
end

-- Function to run the costly HG command once and cache results (rev and user only)
local function run_and_cache_annotate(filepath)
  local buf = vim.api.nvim_get_current_buf()
  local cmd = { 'hg', 'annotate', '-T', "{lines % '{rev},{user}\n'}", filepath }
  log.info('Caching full blame: ' .. table.concat(cmd, ' '))

  local output = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    log.error "hg annotate failed. Is 'hg' installed and is this a Mercurial repo?"
    return nil
  end

  local lines = vim.split(output, '\n', {})
  local annotations = {}

  for i, line in ipairs(lines) do
    local parts = vim.split(line, ',', { plain = true, trimempty = true, limit = 3 })
    if #parts >= 2 then
      annotations[i] = {
        rev = parts[1],
        user = user_name_without_email(parts[2]),
      }
    end
  end

  cache[buf] = annotations
  return annotations
end

local function apply_annotations(buf, annotations)
  local max_rev_length = 0
  local max_user_length = 0

  for _, data in pairs(annotations) do
    max_rev_length = math.max(max_rev_length, #data.rev)
    max_user_length = math.max(max_user_length, #data.user)
  end
  if max_rev_length == 0 then
    return
  end

  vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)

  for i, data in ipairs(annotations) do
    local line_num = i - 1

    local rev_padded = string.format('%-' .. max_rev_length .. 's', data.rev)
    local user_padded = string.format('%-' .. max_user_length .. 's', data.user)

    local virt_text = {
      { '[' .. rev_padded .. ']', 'HgAnnotateRev' },
      { ' ' .. user_padded .. ' ', 'HgAnnotateUser' },
    }

    vim.api.nvim_buf_set_extmark(buf, ns_id, line_num, 0, {
      virt_text = virt_text,
      virt_text_pos = 'inline',
    })
  end
  log.info 'Applied full Hg annotations to margin.'
end

-- Runs on CursorMoved
local function update_blame_at_cursor()
  local buf = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(buf)

  -- Safety check: ensure we are tracking this buffer
  if not cache[buf] then
    return
  end

  -- Get current 1-indexed line number
  local lnum = vim.api.nvim_win_get_cursor(0)[1]

  -- Line data is 1-indexed (lua table)
  local line_data = cache[buf][lnum]

  close_float()

  if not line_data then
    log.debug('No blame data for line ' .. lnum)
    return
  end

  local rev = line_data.rev
  local user = line_data.user

  -- Get commit message (Synchronous call to hg log - this is the slow part)
  local log_cmd = { 'hg', 'log', '-r', rev, '--template', '{desc}', filepath }
  local message_raw = vim.fn.system(log_cmd)

  if vim.v.shell_error ~= 0 then
    log.error('hg log failed for revision ' .. rev)
    return
  end

  local message_lines = vim.split(message_raw, '\n', {})

  local float_content = {
    'Commit: ' .. rev .. ' by ' .. user,
  }

  -- Clean up leading/trailing whitespace and empty lines
  for _, line in ipairs(message_lines) do
    local trimmed_line = line:match '^%s*(.-)%s*$'
    if trimmed_line and trimmed_line ~= '' then
      table.insert(float_content, trimmed_line)
    end
  end

  -- Prepare the buffer for the floating window
  local float_buf = vim.api.nvim_create_buf(false, true) -- Not listed, scratch

  vim.api.nvim_buf_set_lines(float_buf, 0, -1, false, float_content)

  -- Calculate window size and position
  local win_height = math.min(#float_content, 10)
  local win_width = 80 -- Fixed width for message legibility

  -- Get current window dimensions and cursor position
  local win_info = vim.api.nvim_win_get_config(0)
  local current_cursor_row = vim.api.nvim_win_get_cursor(0)[1] - 1 -- 0-indexed row

  local row = current_cursor_row + 1

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

  local main_win_id = vim.api.nvim_get_current_win()
  local col = win_info.width - win_width

  -- Open the floating window
  float_win_id = vim.api.nvim_open_win(float_buf, true, {
    relative = 'win',
    row = row,
    col = col,
    width = win_width,
    height = win_height,
    style = 'minimal',
    border = 'single',
    focusable = false,
  })

  -- Highlight the header/rev line in the float window
  vim.api.nvim_buf_add_highlight(float_buf, ns_id, 'Title', 0, 0, -1)

  vim.api.nvim_set_current_win(main_win_id)
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

    local annotations = run_and_cache_annotate(filepath)

    if annotations then
      apply_annotations(buf, annotations)
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
