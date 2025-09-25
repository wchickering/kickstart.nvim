-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

return {
  'mfussenegger/nvim-dap',
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
    -- 'mfussenegger/nvim-dap-python',
  },
  keys = {
    -- Basic debugging keymaps, feel free to change to your liking!
    {
      '<leader>dc',
      function()
        require('dap').continue()
      end,
      desc = 'Debug: Start/Continue',
    },
    {
      '<leader>di',
      function()
        require('dap').step_into()
      end,
      desc = 'Debug: Step Into',
    },
    {
      '<leader>do',
      function()
        require('dap').step_over()
      end,
      desc = 'Debug: Step Over',
    },
    {
      '<leader>dO',
      function()
        require('dap').step_out()
      end,
      desc = 'Debug: Step Out',
    },
    {
      '<leader>dr',
      function()
        require('dap').run_to_cursor()
      end,
      desc = 'Debug: Run to Cursor',
    },
    {
      '<leader>db',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Debug: Toggle Breakpoint',
    },
    {
      '<leader>dB',
      function()
        require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end,
      desc = 'Debug: Set Breakpoint',
    },
    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    {
      '<leader>du',
      function()
        require('dapui').toggle()
      end,
      desc = 'Debug: See last session result.',
    },
    {
      '<leader>d?',
      function()
        require('dapui').eval(nil, { enter = true })
      end,
      desc = 'Debug: Eval var under cursor.',
    },
    {
      '<leader>dq',
      function()
        require('dap').disconnect()
      end,
      desc = 'Debug: Disconnect Debugger',
    },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

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
        'debugpy',
      },
    }

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
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

    -- -- keymaps
    -- vim.keymap.set('n', '<leader>dc', function()
    --   dap.continue()
    -- end, { desc = 'Debug: Start/Continue' })
    -- vim.keymap.set('n', '<leader>di', function()
    --   dap.step_into()
    -- end, { desc = 'Debug: Step Into' })
    -- vim.keymap.set('n', '<leader>do', function()
    --   dap.step_over()
    -- end, { desc = 'Debug: Step Over' })
    -- vim.keymap.set('n', '<leader>dO', function()
    --   dap.step_out()
    -- end, { desc = 'Debug: Step Out' })
    -- vim.keymap.set('n', '<leader>dr', function()
    --   dap.run_to_cursor()
    -- end, { desc = 'Debug: Run to Cursor' })
    -- vim.keymap.set('n', '<leader>db', function()
    --   dap.toggle_breakpoint()
    -- end, { desc = 'Debug: Toggle Breakpoint' })
    -- vim.keymap.set('n', '<leader>dB', function()
    --   dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
    -- end, { desc = 'Debug: Set Breakpoint' })
    -- vim.keymap.set('n', '<leader>du', function()
    --   dapui.toggle()
    -- end, { desc = 'Debug: See last session result.' })
    -- vim.keymap.set('n', '<leader>d?', function()
    --   dapui.eval(nil, { enter = true })
    -- end, { desc = 'Debug: Eval var under cursor.' })
    -- vim.keymap.set('n', '<leader>dq', function()
    --   dap.terminate()
    -- end, { desc = 'Debug: Terminate Session' })

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Install golang specific config
    require('dap-go').setup {
      delve = {
        -- On Windows delve must be run attached or it crashes.
        -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
        detached = vim.fn.has 'win32' == 0,
      },
    }
  end,
}
