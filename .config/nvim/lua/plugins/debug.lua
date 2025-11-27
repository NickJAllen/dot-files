-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)
--

local should_use_dap_ui = true

local function open_debug_ui()
  if should_use_dap_ui then
    require('dapui').open()
  else
    require('dap-view').open()
  end
end

local function close_debug_ui()
  if should_use_dap_ui then
    require('dapui').close()
  else
    require('dap-view').close()
  end
end

local function toggle_debug_ui()
  if should_use_dap_ui then
    require('dapui').toggle()
  else
    require('dap-view').toggle()
  end
end

local function get_breakpoint_condition(callback)
  vim.ui.input({
    prompt = 'Breakpoint Condition',
  }, callback)
end

local function set_conditional_breakpoint()
  get_breakpoint_condition(function(condition)
    require('dap').set_breakpoint(condition)
  end)
end

return {
  -- NOTE: Yes, you can install new plugins here!
  'mfussenegger/nvim-dap',
  -- NOTE: And you can specify dependencies as well
  dependencies = {
    -- Creates a beautiful debugger UI

    'rcarriga/nvim-dap-ui',

    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',

    -- Installs the debug adapters for you
    'mason-org/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Add your own debuggers here
    'leoluz/nvim-dap-go',
  },
  keys = {
    -- Basic debugging keymaps, feel free to change to your liking!
    {
      '<leader>dd',
      function()
        require('dap').continue()
      end,
      desc = 'Start/Continue',
    },
    {
      '<F5>',
      function()
        require('dap').continue()
      end,
      desc = 'Start/Continue',
    },
    {
      '<leader>dl', -- this is Shift F5 on mac
      function()
        require('dap').run_last()
      end,
      desc = 'Run Last',
    },
    {
      '<F17>', -- this is Shift F5 on mac
      function()
        require('dap').run_last()
      end,
      desc = 'Run Last',
    },
    {
      '<leader>dq',
      function()
        require('dap').terminate()
      end,
      desc = 'Terminate',
    },
    {
      '<F6>',
      function()
        require('dap').terminate()
      end,
      desc = 'Terminate',
    },
    {
      '<leader>dc',
      function()
        require('dap').run_to_cursor()
      end,
      desc = 'Run to Cursor',
    },
    {
      '<leader>dn',
      function()
        require('dap').step_over()
      end,
      desc = 'Step Over',
    },
    {
      '<F10>',
      function()
        require('dap').step_over()
      end,
      desc = 'Step Over',
    },
    {
      '<leader>di',
      function()
        require('dap').step_into()
      end,
      desc = 'Step Into',
    },
    {
      '<F11>',
      function()
        require('dap').step_into()
      end,
      desc = 'Step Into',
    },
    {
      '<leader>do',
      function()
        require('dap').step_out()
      end,
      desc = 'Step Out',
    },
    {
      '<F12>',
      function()
        require('dap').step_out()
      end,
      desc = 'Step Out',
    },
    {
      '<leader>db',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Toggle Breakpoint',
    },
    {
      '<leader>dm',
      function()
        local trace_massage = vim.fn.input 'Enter tracepoint expression: '
        require('dap').set_breakpoint(nil, nil, trace_massage)
      end,
      desc = 'Set Tracepoint Message',
    },
    {
      '<leader>dr',
      function()
        require('dap').restart_frame()
      end,
      desc = 'Restart Frame',
    },
    {
      '<leader>dk',
      function()
        require('dap').up()
      end,
      desc = 'Go Up Stack',
    },
    {
      '<F2>',
      function()
        require('dap').up()
      end,
      desc = 'Go Up Stack',
    },
    {
      '<leader>dj',
      function()
        require('dap').down()
      end,
      desc = 'Go Down Stack',
    },
    {
      '<F3>',
      function()
        require('dap').down()
      end,
      desc = 'Go Down Stack',
    },
    {
      '<leader>dB',
      set_conditional_breakpoint,
      desc = 'Set Conditional Breakpoint',
    },
    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    {
      '<leader>du',
      toggle_debug_ui,
      desc = 'Toggle UI.',
    },
    {
      '<F7>',
      toggle_debug_ui,
      desc = 'Toggle UI.',
    },
  },
  config = function()
    local dap = require 'dap'

    vim.fn.sign_define('DapBreakpoint', { text = '🛑', texthl = '', linehl = '', numhl = '' })

    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_installation = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        'delve',
      },
    }

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    local dapui = require 'dapui'
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
      element_mappings = {
        stacks = {
          open = '<CR>',
          expand = 'o',
        },
      },
    }

    -- Change breakpoint icons
    -- vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
    -- vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
    -- local breakpoint_icons = vim.g.have_nerd_font
    --     and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
    --   or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
    -- for type, icon in pairs(breakpoint_icons) do
    --   local tp = 'Dap' .. type
    --   local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
    --   vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
    -- end

    dap.listeners.after.event_initialized['dapui_config'] = open_debug_ui
    dap.listeners.before.event_terminated['dapui_config'] = close_debug_ui
    dap.listeners.before.event_exited['dapui_config'] = close_debug_ui

    -- Install golang specific config
    require('dap-go').setup {
      delve = {
        -- On Windows delve must be run attached or it crashes.
        -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
        detached = vim.fn.has 'win32' == 0,
      },
    }

    dap.adapters.codelldb = {
      type = 'server',
      port = '${port}',
      executable = {
        command = 'codelldb',
        args = { '--port', '${port}' },
      },
    }
  end,
}
