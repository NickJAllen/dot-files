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
  pcall(vim.cmd, 'wall')
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
  -- log.trace 'About to perform refactoring'
  -- M.save_all()
end

-- Called after an LSP refactoring has completed
function M.after_refactoring_complete()
  -- log.trace 'Refactoring complete'
  -- M.save_all()
  -- M.reload_unmodified_buffers()
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

---@param name string
---@param command string[]
---@param callback function(line : string)
local function select_command_output_line(name, command, callback)
  local picker = require 'snacks.picker'

  vim.fn.jobstart(command, {
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
          source = name,
          items = items,
          layout = { preset = 'select' },
          format = 'text',
          confirm = function(p, item)
            p:close()
            callback(item.text)
          end,
        }
      end
    end,
  })
end

---@param name string
---@param command string[]
---@return string|nil selected_line
function M.await_select_command_output_line(name, command)
  local co = coroutine.running()

  M.select_command_output_line(name, command, function(line)
    local ok, error = coroutine.resume(co, line)
  end)

  return coroutine.yield()
end

function M.open_directory_in_oil()
  local find_command = {
    'fd',
    '--type',
    'd',
    '--color',
    'never',
  }

  select_command_output_line('directories', find_command, function(selected)
    vim.cmd('Oil ' .. selected)
  end)
end

---@param ps_line string
---@return integer|nil pid
local function get_pid(ps_line)
  return ps_line:match '^%s*%S+%s+(%d+)'
end

---@parama callback function(process_id : integer|nil)
function M.select_process_id(callback)
  local command = { 'ps', '-ef' }

  select_command_output_line('process', command, function(selected)
    local pid = get_pid(selected)

    if not pid then
      callback(nil)
    else
      callback(tonumber(pid))
    end
  end)
end

---@return integer|nil pid
function M.await_select_process_id()
  local co = coroutine.running()

  M.select_process_id(function(pid)
    coroutine.resume(co, pid)
  end)

  return coroutine.yield()
end

local function get_random_colorscheme()
  local schemes = {
    'ayu-dark',
    'ayu-mirage',
    'bamboo',
    'catppuccin-mocha',
    'codedark',
    'duskfox',
    'edge',
    'embark',
    'everforest',
    'evergarden',
    'gruvbox-material',
    'hybrid',
    'kanagawa',
    'material-darker',
    'material-deep-ocean',
    'material',
    'melange',
    'min-theme-dark',
    'moonfly',
    'nightfly',
    'nightfox',
    'nord',
    'nordic',
    'oc-2',
    'oc-2-noir',
    'oasis-mirage',
    'okcolors-smooth',
    'onedark',
    'oxocarbon',
    'sherbet',
    'sonokai',
    'teide-darker',
    'teide',
    'thorn',
    'tokyodark',
    'tokyonight-night',
    'vague',
    'vitesse',
    'zephyr',
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

function M.deduplicate_qf()
  local qf = vim.fn.getqflist()
  local seen = {}
  local unique_qf = {}

  for _, entry in ipairs(qf) do
    -- Create a unique ID for each entry
    local id = string.format('%d:%d:%d', entry.bufnr, entry.lnum, entry.col)
    if not seen[id] then
      table.insert(unique_qf, entry)
      seen[id] = true
    end
  end

  vim.fn.setqflist(unique_qf, 'r')
end

return M
