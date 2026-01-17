local M = {}

local log = require('plenary.log').new { plugin = 'nick-utils', level = 'info' }
local jj_snapshot_timer = vim.uv.new_timer()

local function make_jj_snapshot()
  if jj_snapshot_timer and jj_snapshot_timer:is_active() then
    jj_snapshot_timer:stop()
  end

  log.trace 'Making snapshot using Jujutsu'
  vim.fn.system 'jj status'
end

---Call a callback after all pending LSP requests are done for the current buffer
---@param callback fun()
local function after_pending_lsp(callback)
  local bufnr = vim.api.nvim_get_current_buf()

  local function check()
    local pending = false
    for _, client in pairs(vim.lsp.get_clients { bufnr = bufnr }) do
      -- Check if client has any pending requests
      if #client.requests ~= 0 then
        pending = true
        break
      end
    end

    if pending then
      -- If there are still pending requests, check again after 50ms
      log.info 'Waiting for pending LSP requests to complete'
      vim.defer_fn(check, 50)
    else
      -- All requests done, call the callback
      callback()
    end
  end

  check()
end

---@param bufnr integer
function M.delete_buffer(bufnr)
  require('snacks.bufdelete').delete { buf = bufnr }
end

function M.delete_current_buffer()
  require('snacks.bufdelete').delete()
end

-- Saves all files
function M.save_all()
  log.trace 'Saving all files'
  vim.cmd 'wall'
  make_jj_snapshot()
end

function M.jj_snapshot()
  if not jj_snapshot_timer then
    make_jj_snapshot()
    return
  end

  if jj_snapshot_timer:is_active() then
    jj_snapshot_timer:stop()
  end

  jj_snapshot_timer:start(100, 0, vim.schedule_wrap(make_jj_snapshot))
end

-- Called before we are about to perform an LSP refactoring
function M.before_refactoring()
  log.trace 'About to perform refactoring'
  M.save_all()
end

-- Called after an LSP refactoring has completed
function M.after_refactoring_complete()
  log.trace 'Refactoring complete'
  M.save_all()
  M.reload_unmodified_buffers()
end

-- Reloads any files from disk that haven't been modified in neovim
function M.reload_unmodified_buffers()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      local bo = vim.bo[buf] -- buffer-local options table
      local name = vim.api.nvim_buf_get_name(buf)

      -- only reload real files that are modifiable and not modified
      if name ~= '' and vim.fn.filereadable(name) == 1 and bo.modifiable and not bo.modified then
        -- run checktime in that buffer's context to pick up external changes
        vim.api.nvim_buf_call(buf, function()
          vim.cmd 'silent! edit!'
          log.trace('Reloaded unmodified buffer ' .. name)
        end)
      end
    end
  end
end

-- Closes other buffers than the current one that are normal files and not modified
function M.delete_other_unmodified_buffers()
  local current = vim.api.nvim_get_current_buf()

  if vim.bo[current].buftype ~= '' then
    return
  end

  local bufs = vim.api.nvim_list_bufs()

  for _, buf in ipairs(bufs) do
    if buf ~= current then
      local modified = vim.bo[buf].modified
      local buftype = vim.bo[buf].buftype

      -- only close normal, unmodified buffers
      if not modified and buftype == '' then
        M.delete_buffer(buf)
      end
    end
  end
end

function M.open_messages()
  local buf = vim.api.nvim_create_buf(false, true)
  local output = vim.fn.execute 'messages'
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(output, '\n'))
  vim.api.nvim_set_current_buf(buf)
end

---@param bufnr integer
function M.delete_buffer_and_file(bufnr)
  local buftype = vim.bo[bufnr].buftype
  local filepath = vim.api.nvim_buf_get_name(bufnr)

  -- Delete the file if it exists
  if filepath ~= '' and buftype == '' and vim.loop.fs_stat(filepath) and vim.fn.confirm('Really delete ' .. filepath .. '?', '&Yes\n&No') then
    M.delete_buffer(bufnr)

    os.remove(filepath)
  end
end

function M.delete_current_buffer_and_file()
  M.delete_buffer_and_file(vim.api.nvim_get_current_buf())
end

function M.open_directory_in_oil()
  local picker = require 'snacks.picker'

  local find_command = {
    'fd',
    '--type',
    'd',
    '--color',
    'never',
  }

  vim.fn.jobstart(find_command, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data then
        local filtered = vim.tbl_filter(function(el)
          return el ~= ''
        end, data)

        local items = {}
        for _, v in ipairs(filtered) do
          table.insert(items, { text = v })
        end

        ---@module 'snacks'
        picker.pick {
          source = 'directories',
          items = items,
          layout = { preset = 'select' },
          format = 'text',
          confirm = function(p, item)
            p:close()
            vim.cmd('Oil ' .. item.text)
          end,
        }
      end
    end,
  })
end

---@return string[]
local function get_quickfix_files()
  local qf_list = vim.fn.getqflist()

  local result = {}

  ---@type table<string, boolean>
  local file_set = {}

  for _, item in ipairs(qf_list) do
    local bufnr = item.bufnr
    local file = item.filename

    if (not file or file == '') and bufnr and bufnr ~= 0 then
      file = vim.fn.bufname(bufnr)
    end

    if file and file ~= '' then
      if not file_set[file] then
        file_set[file] = true
        table.insert(result, { bufnr, file })
      end
    end
  end

  for file, _ in ipairs(file_set) do
    table.insert(result, file)
  end

  return result
end

---@class FileLocation
---@field file string
---@field line integer
---@field col integer
local FileLocation = {}
FileLocation.__index = FileLocation

---@param file string
---@param line integer
---@param col integer
---@return FileLocation
function FileLocation.new(file, line, col)
  local self = setmetatable({}, FileLocation)
  self.file = file
  self.line = line
  self.col = col
  return self
end

M.FileLocation = FileLocation

---@return FileLocation[]
function M.get_quickfix_file_locations()
  local qf_list = vim.fn.getqflist()

  local result = {}

  for _, item in ipairs(qf_list) do
    local file = item.filename
    local bufnr = item.bufnr

    if (not file or file == '') and bufnr and bufnr ~= 0 then
      file = vim.fn.bufname(bufnr)
    end

    local line_num = item.lnum
    local col_num = item.col

    if file and file ~= '' and line_num and col_num then
      table.insert(result, FileLocation.new(file, line_num, col_num))
    end
  end

  ---@param a FileLocation
  ---@param b FileLocation
  local function qf_sort_comparator(a, b)
    -- 1. Sort by filename ascending
    local file_a = a.file
    local file_b = b.file

    if file_a ~= file_b then
      return file_a < file_b -- Ascending file path sort
    end

    -- 2. If files are the same, sort by line number descending (reverse order)
    local line_a = a.line
    local line_b = b.line

    if line_a ~= line_b then
      -- return line_a > line_b means item 'a' comes before item 'b' if a's line is greater.
      return line_a > line_b
    end

    local col_a = a.col
    local col_b = b.col

    return col_a > col_b
  end

  table.sort(result, qf_sort_comparator)

  return result
end

function M.quickfix_file_do(command_template)
  -- TODO
end

---Check if a buffer exists for a file path
---@param filepath string
---@return number|nil bufnr  -- returns buffer number if found
local function get_bufnr_for_file(filepath)
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      local bufname = vim.api.nvim_buf_get_name(bufnr)
      -- Normalize paths for comparison
      if vim.fn.fnamemodify(bufname, ':p') == vim.fn.fnamemodify(filepath, ':p') then
        return bufnr
      end
    end
  end
  return nil
end

local should_cancel = false
local is_running_actions = false

function M.cancel_actions()
  should_cancel = true
end

---@alias action_func function(bufnr : integer, file : string, line : integer, col : integer, completed_callback : function())

---@param action_func action_func
---@param bufnr integer
---@param file string
---@param line integer
---@param col integer
---@param completed_callback function()
local function call_action_func(action_func, bufnr, file, line, col, completed_callback)
  after_pending_lsp(function()
    action_func(bufnr, file, line, col, completed_callback)
  end)
end

---@param action_funcs action_func[]
---@param bufnr integer
---@param file string
---@param line integer
---@param col integer
---@param all_completed_callback function()
local function call_all_action_funcs(action_funcs, bufnr, file, line, col, all_completed_callback)
  local i = 1

  local function run_next_func()
    if i > #action_funcs then
      all_completed_callback()
      return
    end

    local f = action_funcs[i]
    i = i + 1
    call_action_func(f, bufnr, file, line, col, run_next_func)
  end

  run_next_func() -- start the chain
end

-- Runs an action on each file location in the list without blocking the UI
--
---@param file_locations FileLocation[]
---@param action_func action_func
function M.for_each_file_location(file_locations, action_func)
  if #file_locations == 0 then
    return
  end

  if is_running_actions then
    log.error 'Currently performing actions - not starting new actions'
    return
  end

  local buffers_to_close = {}

  local index = 1

  local function process_next_file_location()
    local has_finished = index > #file_locations

    if has_finished or should_cancel then
      if has_finished then
        log.info('Finished processing all ' .. #file_locations .. ' file locations.')
      else
        log.info 'Actions canceled'
      end

      for bufnr, _ in ipairs(buffers_to_close) do
        vim.api.nvim_buf_call(bufnr, function()
          log.info('Saving and closing ' .. vim.api.nvim_buf_get_name(bufnr))
          pcall(vim.cmd, 'write')
          M.delete_buffer(bufnr)
        end)
      end

      should_cancel = false
      is_running_actions = false

      return
    end

    local file_location = file_locations[index]
    local file = file_location.file
    local line = file_location.line
    local col = file_location.col

    log.info(string.format('%d / %d Running action on file %s line %d', index, #file_locations, file, line))

    vim.schedule(function()
      local bufnr = get_bufnr_for_file(file)

      if not bufnr then
        bufnr = vim.fn.bufadd(file)
        vim.fn.bufload(bufnr)
        buffers_to_close[bufnr] = true
      end

      vim.api.nvim_set_current_buf(bufnr)

      vim.api.nvim_buf_call(bufnr, function()
        vim.api.nvim_win_set_cursor(0, { line, col - 1 })

        pcall(vim.cmd, 'stopinsert')

        call_action_func(action_func, bufnr, file, line, col, function()
          index = index + 1
          process_next_file_location()
        end)
      end)
    end)
  end

  log.info(string.format('Starting automated action on %d file locations', #file_locations))

  M.save_all()

  is_running_actions = true
  should_cancel = false
  process_next_file_location()
end

-- Runs an action on each item in the quickfix list
--
---@param action_func action_func
function M.for_each_quickfix_item(action_func)
  local quickfix_items = M.get_quickfix_file_locations()

  if #quickfix_items == 0 then
    log.error 'Quickfix list is empty. Nothing to process.'
    return
  end

  M.for_each_file_location(quickfix_items, action_func)
end

-- Runs the supplied ex command on each item in the quickfix list
---@param command string The command to run
function M.quickfix_item_do_command(command)
  M.for_each_quickfix_item(function(_, file, line, col, completed_callback)
    local actual_command = command

    actual_command:gsub('$FILE', file)
    actual_command:gsub('$LINE', line)
    actual_command:gsub('$COL', col)

    pcall(vim.cmd, actual_command)
    completed_callback()
  end)
end

-- Asks the user what command to run on each item in the quickfix list
function M.quickfix_item_do()
  local quickfix_items = M.get_quickfix_file_locations()

  if #quickfix_items == 0 then
    log.error 'Quickfix list is empty. Nothing to process.'
    return
  end

  local command = vim.fn.input('Enter command to run for each item of the ' .. #quickfix_items .. ' in the quickfix list:\n')

  M.quickfix_item_do_command(command)
end

local function get_random_colorscheme()
  local schemes = {
    'duskfox',
    'nightfox',
    'onedark',
    'catppuccin-mocha',
    'tokyonight-night',
    'kanagawa',
    'thorn',
    'minicyan',
    'gruvbox-material',
    'material',
    'material-darker',
    'material-deep-ocean',
    'sonakai',
    'nord',
    'nordic',
    'solarized-osaka',
    'everforest',
    'tokyodark',
    'edge',
    'bamboo',
  }

  while true do
    local scheme = schemes[math.random(#schemes)]

    if scheme ~= vim.g.colors_name then
      return scheme
    end
  end
end

function M.choose_random_colorscheme()
  local scheme = get_random_colorscheme()

  local ok, _ = pcall(vim.cmd, 'colorscheme ' .. scheme)

  if ok then
    vim.notify('Colorscheme ' .. scheme)
  else
    vim.notify('Colorscheme ' .. scheme .. ' not found!', vim.log.levels.ERROR)
  end
end

return M
