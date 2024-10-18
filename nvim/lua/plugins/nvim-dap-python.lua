return {
  'mfussenegger/nvim-dap-python',
  ft = 'python',
  dependencies = {
    'mfussenegger/nvim-dap',
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
  },
  config = function(_, _)
    local path = '~/.local/share/nvim/mason/packages/debugpy/venv/bin/python'
    require('dap-python').setup(path)
  end,
}
