return {
  ---@module 'lazy'
  ---@type LazySpec
  {
    'supermaven-inc/supermaven-nvim',
    dependencies = { 'saghen/blink.compat' },
    cmd = {
      'SupermavenStart',
      -- 'SupermavenUseFree',
      -- 'SupermavenUsePro',
    },
    opts = {
      keymaps = {
        accept_suggestion = nil, -- handled by nvim-cmp / blink.cmp
      },
      disable_inline_completion = true,
      ignore_filetypes = { 'bigfile', 'snacks_input', 'snacks_notif' },
    },
  },

  {
    'saghen/blink.cmp',
    optional = true,
    opts = {
      sources = {
        default = { 'supermaven' },
        providers = {
          supermaven = {
            name = '󰰣',
            opts = {
              cmp_name = 'supermaven',
            },
            module = 'blink.compat.source',
            score_offset = 100,
            async = true,
          },
        },
      },
    },
  },

  {
    'nvim-lualine/lualine.nvim',
    optional = true,
    opts = function(_, opts)
      table.insert(opts.sections.lualine_x, 4, {
        function() return '󰰣' end,
        cond = function()
          local supermaven_config = require('lazy.core.config').plugins['supermaven-nvim']
          if not supermaven_config or not supermaven_config._.loaded then return false end
          return require('supermaven-nvim.api').is_running()
        end,
        separator = '',
      })
    end,
  },
}
