return {
  {
    'stevearc/overseer.nvim',
    cmd = { 'OverseerToggle', 'OverseerRun', 'OverseerOpen', 'OverseerClose' },
    keys = {
      { '<leader>co', '<cmd>OverseerRun<CR>', desc = 'Overseer run' },
      { '<leader>cO', '<cmd>OverseerToggle<CR>', desc = 'Overseer toggle' },
    },
    opts = function(_, _)
      -- Retrieve the current lualine configuration
      local config = require('lualine').get_config()

      table.insert(config.sections.lualine_x, 1, {
        'overseer',
        separator = '',
      })

      -- Reapply the updated configuration
      require('lualine').setup(config)

      return {
        task_list = {
          direction = 'right',
          width = 80,
          default_detail = 2,
          bindings = {
            ['?'] = 'ShowHelp',
            ['g?'] = 'ShowHelp',
            ['<CR>'] = 'RunAction',
            ['<C-e>'] = 'Edit',
            ['o'] = 'Open',
            ['<C-v>'] = 'OpenVsplit',
            ['<C-s>'] = 'OpenSplit',
            ['<C-f>'] = 'OpenFloat',
            ['<C-q>'] = 'OpenQuickFix',
            ['p'] = 'TogglePreview',
            ['<C-l>'] = false,
            ['<C-h>'] = false,
            ['L'] = 'IncreaseAllDetail',
            ['H'] = 'DecreaseAllDetail',
            ['['] = 'DecreaseWidth',
            [']'] = 'IncreaseWidth',
            ['{'] = 'PrevTask',
            ['}'] = 'NextTask',
            ['<C-k>'] = 'ScrollOutputUp',
            ['<C-j>'] = 'ScrollOutputDown',
            ['q'] = 'Close',
          },
        },
      }
    end,
  },
}
