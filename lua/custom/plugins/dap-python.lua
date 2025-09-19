return {
  'mfussenegger/nvim-dap-python',
  ft = 'python',
  dependencies = {
    'mfussenegger/nvim-dap',
  },
  config = function()
    local python_path = vim.fn.exepath 'python3' or vim.fn.exepath 'python'
    require('dap-python').setup(python_path)

    -- Add uvicorn launch configuration
    table.insert(require('dap').configurations.python, {
      type = 'python',
      request = 'launch',
      name = 'Launch uvicorn',
      module = 'uvicorn',
      args = { 'main:app', '--reload', '--host', '0.0.0.0', '--port', '8000' },
      console = 'integratedTerminal',
      cwd = '${workspaceFolder}',
    })
  end,
}
