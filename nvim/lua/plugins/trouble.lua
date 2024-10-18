return {
  'folke/trouble.nvim',
  event = { 'BufNewFile', 'BufReadPost' },
  cmd = 'Trouble',
  opts = {}, -- for default options, refer to the configuration section for custom setup.
  keys = {
    {
      '<leader>xx',
      '<cmd>Trouble diagnostics toggle<cr>',
      desc = 'Diagnostics (Trouble)',
    },
    {
      '<leader>xX',
      '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
      desc = 'Buffer Diagnostics (Trouble)',
    },
    {
      '<leader>cs',
      '<cmd>Trouble symbols toggle focus=false<cr>',
      desc = 'Symbols (Trouble)',
    },
    {
      '<leader>cS',
      '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
      desc = 'LSP Definitions / references / ... (Trouble)',
    },
    {
      '<leader>xl',
      '<cmd>Trouble loclist toggle<cr>',
      desc = 'Location List (Trouble)',
    },
    {
      '<leader>xq',
      '<cmd>Trouble qflist toggle<cr>',
      desc = 'Quickfix List (Trouble)',
    },
    {
      '<leader>xt',
      '<cmd>Trouble todo toggle<cr>',
      desc = 'Todos (Trouble)',
    },
    {
      '<leader>xT',
      '<cmd>Trouble telescope toggle<cr>',
      desc = 'Telescope (Trouble)',
    },
    -- Borrowed from LazyVim
    {
      '[q',
      function()
        if require('trouble').is_open() then
          require('trouble').prev({ skip_groups = true, jump = true })
        else
          local ok, err = pcall(vim.cmd.cprev)
          if not ok then vim.notify(err, vim.log.levels.ERROR) end
        end
      end,
      desc = 'Previous Trouble/Quickfix Item',
    },
    {
      ']q',
      function()
        if require('trouble').is_open() then
          require('trouble').next({ skip_groups = true, jump = true })
        else
          local ok, err = pcall(vim.cmd.cnext)
          if not ok then vim.notify(err, vim.log.levels.ERROR) end
        end
      end,
      desc = 'Next Trouble/Quickfix Item',
    },
    {
      '<leader>xQ',
      '<cmd>Trouble close<cr>',
      desc = 'Close Trouble',
    },
  },

  config = function(_, opts)
    local trouble = require('trouble')
    trouble.setup(opts)

    --if lualine is not loaded, bail out
    local lualine_lazy_config = require('lazy.core.config').plugins['lualine.nvim']
    if not lualine_lazy_config or not lualine_lazy_config._.loaded then return nil end

    local trouble_symbols = trouble.statusline({
      mode = 'symbols',
      groups = {},
      title = false,
      filter = { range = true },
      format = '{kind_icon}{symbol.name:Normal}',
      hl_group = 'lualine_c_normal',
    })

    local config = require('lualine.config').get_config()

    table.insert(config.sections.lualine_c, {
      trouble_symbols and trouble_symbols.get,
      cond = function() return vim.b.trouble_lualine ~= false and vim.fn.winwidth(0) > 100 and trouble_symbols.has() end,
    })

    require('lualine').setup(config)
  end,
}
