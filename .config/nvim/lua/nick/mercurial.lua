local M = {}
-- Create a unique namespace for the extmarks to avoid conflicts
local ns_id = vim.api.nvim_create_namespace 'HgAnnotate'
-- Assuming plenary.log is available for better messages
local log = require('plenary.log').new { plugin = 'hg-annotate', level = 'info' }

-- Globals for state management
-- cache stores { [bufnr] = { [line_num] = {rev, user}, ... } }
local annotate_cache = {}
local augroup_name = 'HgAnnotateGroup'
-- Create a new augroup specifically for the CursorMoved autocommand
local augroup_id = vim.api.nvim_create_augroup(augroup_name, { clear = true })
local commit_info_win_id = nil -- ID of the floating window showing the commit message

local function close_commit_info()
  if commit_info_win_id and vim.api.nvim_win_is_valid(commit_info_win_id) then
    local float_buf_id = vim.api.nvim_win_get_buf(commit_info_win_id)

    vim.api.nvim_win_close(commit_info_win_id, true)

    if vim.api.nvim_buf_is_loaded(float_buf_id) then
      vim.api.nvim_buf_delete(float_buf_id, {})
    end
  end

  commit_info_win_id = nil
end

-- Clears all cached annotation data for a buffer
local function clear_annotate_cache(buf)
  if not buf then
    buf = vim.api.nvim_get_current_buf()
  end

  vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)

  annotate_cache[buf] = nil

  close_commit_info()

  log.trace('Cleared Hg annotations for buffer: ' .. buf)
end

---@param user string
---@return string
local function user_name_without_email(user)
  local email_start = user:find ' <'

  if not email_start or email_start < 3 then
    return user
  end

  return user:sub(1, email_start - 1)
end

-- Function to run the costly HG command once and cache results (rev and user only)
---@param filepath string
local function run_and_cache_annotate(filepath)
  local buf = vim.api.nvim_get_current_buf()
  local cmd = { 'hg', 'annotate', '-T', "{lines % '{rev},{user}\n'}", filepath }
  log.trace('Caching full blame: ' .. table.concat(cmd, ' '))

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

  annotate_cache[buf] = annotations

  return annotations
end

---@param buf integer Buffer number to apply annotations to
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
      { rev_padded .. ' ', 'HgAnnotateRev' },
      { ' ' .. user_padded .. ' ', 'HgAnnotateUser' },
    }

    vim.api.nvim_buf_set_extmark(buf, ns_id, line_num, 0, {
      virt_text = virt_text,
      virt_text_pos = 'inline',
    })
  end

  log.trace 'Applied full Hg annotations to margin.'
end

-- Shows commit info for the current line
local function show_commit_info_at_cursor()
  local buf = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(buf)

  if not annotate_cache[buf] then
    return
  end

  local line_number = vim.api.nvim_win_get_cursor(0)[1]
  local line_data = annotate_cache[buf][line_number]

  close_commit_info()

  if not line_data then
    log.debug('No blame data for line ' .. line_number)
    return
  end

  local rev = line_data.rev
  local user = line_data.user

  local log_cmd = { 'hg', 'log', '-r', rev, '--template', 'Date: {date|isodate}\n{desc}', filepath }
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

  if row + win_height > win_info.height then
    row = current_cursor_row - win_height
  end

  if row < 0 then
    row = 0
  end

  local main_win_id = vim.api.nvim_get_current_win()
  local col = win_info.width - win_width

  commit_info_win_id = vim.api.nvim_open_win(float_buf, true, {
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
  for line = 0, 1 do
    vim.api.nvim_buf_add_highlight(float_buf, ns_id, 'Title', line, 0, -1)
  end

  vim.api.nvim_set_current_win(main_win_id)
end

--- Toggles the visibility and tracking of Hg Annotate.
function M.toggle_annotations()
  local buf = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(buf)

  if annotate_cache[buf] then
    -- Annotation is ON -> Turn OFF
    -- Clear the autocommand specific to this buffer
    vim.api.nvim_clear_autocmds { group = augroup_name, buffer = buf }
    clear_annotate_cache(buf)
    log.trace 'Hg Annotate: OFF'
  else
    -- Annotation is OFF -> Turn ON
    -- Check if file is valid
    if filepath == '' or not vim.fn.isdirectory(vim.fn.fnamemodify(filepath, ':h')) then
      log.error 'Hg Annotate: Not a valid file or Mercurial repo.'
      return
    end

    local annotations = run_and_cache_annotate(filepath)

    if annotations then
      apply_annotations(buf, annotations)
      -- Setup autocommand to update blame on cursor movement
      vim.api.nvim_create_autocmd('CursorMoved', {
        group = augroup_id,
        buffer = buf,
        callback = show_commit_info_at_cursor,
        desc = 'Update Hg blame text on cursor move',
      })

      -- Run immediately on toggle
      show_commit_info_at_cursor()

      log.trace 'Hg Annotate: ON (Tracking current line)'
    end
  end
end

-- Define the highlight groups needed for the virtual text appearance and floating window
vim.cmd [[highlight default link HgAnnotateRev String]]
vim.cmd [[highlight default link HgAnnotateUser Identifier]]
vim.cmd [[highlight default link HgAnnotateText Comment]]
vim.cmd [[highlight default link Title Normal]]

return M
