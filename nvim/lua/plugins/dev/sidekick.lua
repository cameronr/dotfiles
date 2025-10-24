return {
  {
    'folke/sidekick.nvim',
    enabled = true,
    keys = {
      {
        '<tab>',
        function()
          -- if there is a next edit, jump to it, otherwise apply it if any
          if not require('sidekick').nes_jump_or_apply() then
            return '<Tab>' -- fallback to normal tab
          end
        end,
        expr = true,
        desc = 'Goto/Apply Next Edit Suggestion',
      },
      -- {
      --   '<c-.>',
      --   function() require('sidekick.cli').focus() end,
      --   desc = 'Sidekick Switch Focus',
      --   mode = { 'n', 'v' },
      -- },
      {
        '<leader>aS',
        function() require('sidekick.cli').toggle({ name = 'opencode', focus = true }) end,
        desc = 'Sidekick Toggle CLI',
        mode = { 'n', 'v' },
      },
      -- {
      --   '<leader>aS',
      --   function() require('sidekick.cli').toggle({ name = 'claude', focus = true }) end,
      --   desc = 'Sidekick Claude Toggle',
      --   mode = { 'n', 'v' },
      -- },
      {
        '<leader>aP',
        function() require('sidekick.cli').select_prompt() end,
        desc = 'Sidekick Ask Prompt',
        mode = { 'n', 'v' },
      },
    },
    opts = {
      -- add any options here
      -- cli = {
      --   mux = {
      --     backend = 'tmux',
      --     enabled = true,
      --   },
      -- },
    },
    config = function(_, opts)
      require('sidekick').setup(opts)

      if Snacks then
        Snacks.toggle({
          name = 'Copilot NES',
          get = function() return vim.g.sidekick_nes == nil or vim.g_sidekick_nes end,
          set = function(state) vim.g.sidekick_nes = state end,
        }):map('<leader>aN')
      end
    end,
  },
  {
    'nvim-lualine/lualine.nvim',
    optional = true,
    opts = function(_, opts)
      local lazy_sidekick = require('lazy.core.config').plugins['sidekick.nvim']
      if not lazy_sidekick or lazy_sidekick._.loaded then return end
      table.insert(opts.sections.lualine_x, {
        function() return ' ' end,
        color = function()
          local status = require('sidekick.status').get()
          if status then return status.kind == 'Error' and 'DiagnosticError' or status.busy and 'DiagnosticWarn' or 'Special' end
        end,
        cond = function()
          if vim.g.sidekick_nes == false or vim.b.sidekick_nes == false then return false end
          local status = require('sidekick.status')
          return status.get() ~= nil
        end,
      })
    end,
  },
}
