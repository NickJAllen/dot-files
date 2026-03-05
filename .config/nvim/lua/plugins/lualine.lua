local function macro_status()
  local reg = vim.fn.reg_recording()

  if reg ~= '' then
    return '🔴 Recording @' .. reg
  end

  return ''
end

vim.api.nvim_create_autocmd({ 'RecordingEnter', 'RecordingLeave' }, {
  callback = function()
    require('lualine').refresh()
  end,
})

local tmux_session_name = ''

local function update_tmux_session_name()
  vim.system({ 'tmux', 'display-message', '-p', '#S' }, { text = true }, function(obj)
    if obj.code == 0 then
      vim.schedule(function()
        local s = obj.stdout:gsub('%s+$', '')

        if s ~= tmux_session_name then
          tmux_session_name = s
          require('lualine').refresh()
        end
      end)
    end
  end)
end

local vcs_status = ''

local function update_vcs_status()
  vim.system({ 'vcs-status.sh' }, { text = true }, function(obj)
    if obj.code == 0 then
      vim.schedule(function()
        local s = obj.stdout:gsub('%s+$', '')

        if s ~= vcs_status then
          vcs_status = s
          require('lualine').refresh()
        end
      end)
    end
  end)
end

local function update_status()
  update_tmux_session_name()
  update_vcs_status()
end

local timer = vim.loop.new_timer()
timer:start(0, 5000, update_status)

return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    lazy = false,
    opts = {
      options = {
        icons_enabled = true,
        theme = 'auto',
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        always_show_tabline = true,
        globalstatus = false,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
          refresh_time = 16, -- ~60fps
          events = {
            'WinEnter',
            'BufEnter',
            'BufWritePost',
            'SessionLoadPost',
            'FileChangedShellPost',
            'VimResized',
            'Filetype',
            'CursorMoved',
            'CursorMovedI',
            'ModeChanged',
          },
        },
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = {
          'branch',
          'diff',
          'diagnostics',
          {
            macro_status,
            color = { fg = '#ff9e64', gui = 'bold' },
          },
        },
        lualine_c = {
          {
            'filename',
            path = 3,
            symbols = {
              modified = '[*]', -- Text to show when the file is modified.
              readonly = '[-]', -- Text to show when the file is non-modifiable or readonly.
              unnamed = '[No Name]', -- Text to show for unnamed buffers.
              newfile = '[New]', -- Text to show for newly created file before first write
            },
          },
        },
        lualine_x = {
          {
            function()
              local host = vim.uv.os_gethostname()
              if os.getenv 'SSH_CLIENT' or os.getenv 'SSH_TTY' then
                return '󰒋 ' .. host
              end
              return '' -- Hide it if we're just on local machine
            end,
            color = { fg = '#7aa2f7' }, -- Optional color
          },
          {
            function()
              return tmux_session_name ~= '' and ('󱫋 ' .. tmux_session_name) or ''
            end,
            color = { fg = '#ff9e64', gui = 'bold' },
          },
          {
            function()
              return vcs_status ~= '' and ('󰘬 ' .. vcs_status) or ''
            end,
            color = { fg = '#ff9e64', gui = 'bold' },
          },
          'encoding',
          'fileformat',
          'filetype',
        },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = {},
    },
  },
}
