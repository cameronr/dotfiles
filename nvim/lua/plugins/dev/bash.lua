return {
  {
    'mfussenegger/nvim-dap',
    optional = true,
    opts = function()
      local dap = require('dap')

      local BASH_DEBUG_ADAPTER_BIN = vim.fn.stdpath('data') .. '/mason/packages/bash-debug-adapter/bash-debug-adapter'
      local BASHDB_DIR = vim.fn.stdpath('data') .. '/mason/packages/bash-debug-adapter/extension/bashdb_dir'

      dap.adapters['bash'] = {
        type = 'executable',
        command = BASH_DEBUG_ADAPTER_BIN,
      }
      dap.configurations['sh'] = {
        {
          name = 'Launch Bash debugger',
          type = 'bash',
          request = 'launch',
          program = '${file}',
          cwd = '${fileDirname}',
          pathBashdb = BASHDB_DIR .. '/bashdb',
          pathBashdbLib = BASHDB_DIR,
          pathBash = 'bash',
          pathCat = 'cat',
          pathMkfifo = 'mkfifo',
          pathPkill = 'pkill',
          env = {},
          args = {},
          -- showDebugOutput = true,
          -- trace = true,
        },
      }
    end,
  },
}
