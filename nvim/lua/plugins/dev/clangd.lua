return {
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = { 'clangd' },
    },
  },
  {
    'stevearc/conform.nvim',
    optional = true,
    ---@module 'conform'
    ---@type conform.setupOpts
    opts = {
      formatters_by_ft = {
        c = { 'uncrustify' },
        cpp = { 'uncrustify' },
      },
    },
  },

  {
    'p00f/clangd_extensions.nvim',
    lazy = true,
    config = function() end,
    opts = {
      inlay_hints = {
        inline = false,
      },
      ast = {
        --These require codicons (https://github.com/microsoft/vscode-codicons)
        role_icons = {
          type = '',
          declaration = '',
          expression = '',
          specifier = '',
          statement = '',
          ['template argument'] = '',
        },
        kind_icons = {
          Compound = '',
          Recovery = '',
          TranslationUnit = '',
          PackExpansion = '',
          TemplateTypeParm = '',
          TemplateTemplateParm = '',
          TemplateParamObject = '',
        },
      },
    },
  },
  {
    'mfussenegger/nvim-dap',
    optional = true,
    opts = function()
      local dap = require('dap')
      if not dap.adapters['codelldb'] then
        require('dap').adapters['codelldb'] = {
          type = 'server',
          host = 'localhost',
          port = '${port}',
          executable = {
            command = 'codelldb',
            args = {
              '--port',
              '${port}',
            },
          },
        }
      end
      for _, lang in ipairs({ 'c', 'cpp' }) do
        dap.configurations[lang] = {
          {
            type = 'codelldb',
            request = 'launch',
            name = 'Launch file',
            program = function() return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file') end,
            cwd = '${workspaceFolder}',
          },
          {
            type = 'codelldb',
            request = 'attach',
            name = 'Attach to process',
            pid = require('dap.utils').pick_process,
            cwd = '${workspaceFolder}',
          },
        }
      end
    end,
  },
  -- {
  --   'Civitasv/cmake-tools.nvim',
  --   lazy = true,
  --   init = function()
  --     vim.api.nvim_create_autocmd('User', {
  --       pattern = 'VeryLazy',
  --       once = true,
  --       callback = function()
  --         local loaded = false
  --         local function check()
  --           local cwd = vim.uv.cwd()
  --           if vim.fn.filereadable(cwd .. '/CMakeLists.txt') == 1 then
  --             require('lazy').load({ plugins = { 'cmake-tools.nvim' } })
  --             loaded = true
  --           end
  --         end
  --         check()
  --         vim.api.nvim_create_autocmd('DirChanged', {
  --           callback = function()
  --             if not loaded then check() end
  --           end,
  --         })
  --       end,
  --     })
  --   end,
  --   opts = {},
  -- },
}
