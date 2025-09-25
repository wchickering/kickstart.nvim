return {
  'mfussenegger/nvim-dap-python',
  ft = 'python',
  dependencies = {
    'mfussenegger/nvim-dap',
  },
  config = function()
    local dap = require 'dap'

    -- debugpy adapter configuration
    dap.adapters.python = {
      type = 'server',
      host = '127.0.0.1',
      port = 5678,
    }

    local python_path = vim.fn.exepath 'python3' or vim.fn.exepath 'python'
    require('dap-python').setup(python_path)

    -- Add uvicorn launch configuration
    table.insert(dap.configurations.python, {
      type = 'python',
      request = 'launch',
      name = 'Launch uvicorn',
      module = 'uvicorn',
      args = { 'main:app', '--reload', '--host', '0.0.0.0', '--port', '8000' },
      console = 'integratedTerminal',
      cwd = '${workspaceFolder}',
    })

    -- Add docker attack configuration
    table.insert(dap.configurations.python, {
      type = 'python',
      request = 'attach',
      name = 'Attach to Docker',
      host = '127.0.0.1',
      port = 5678,
      pathMappings = {
        {
          localRoot = vim.fn.getcwd() .. '/src',
          remoteRoot = '/app/src',
        },
      },
      justMyCode = false,
      console = 'integratedTerminal',
      logToFile = true,
    })
  end,
}
