return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'mfussenegger/nvim-dap-python',
    'rcarriga/nvim-dap-ui',
    'theHamsta/nvim-dap-virtual-text',
    'nvim-neotest/nvim-nio',
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    dapui.setup {}

    require('nvim-dap-virtual-text').setup {
      commented = true, -- Show virtual text alongside comment
    }

    -- toggle breakpoint
    vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint)

    -- run to cursor
    vim.keymap.set('n', '<leader>dr', dap.run_to_cursor)

    -- continue/start
    vim.keymap.set('n', '<leader>dc', dap.continue)

    -- step over
    vim.keymap.set('n', '<leader>do', dap.step_over)

    -- step into
    vim.keymap.set('n', '<leader>di', dap.step_into)

    -- step out
    vim.keymap.set('n', '<leader>dO', dap.step_out)

    -- terminate debugging
    vim.keymap.set('n', '<leader>dq', dap.terminate)

    -- toggle UI
    vim.keymap.set('n', '<leader>du', dapui.toggle)

    -- eval var under cursor
    vim.keymap.set('n', '<leader>d?', function()
      dapui.eval(nil, { enter = true })
    end)

    -- automatically open/close UI
    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end
  end,
}
