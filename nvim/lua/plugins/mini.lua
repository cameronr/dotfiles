return {
  ---@module 'lazy'
  ---@type LazySpec
  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    event = 'VeryLazy',

    -- Mock web-dev-icons with mini-icons
    init = function()
      package.preload['nvim-web-devicons'] = function()
        require('mini.icons').mock_nvim_web_devicons()
        return package.loaded['nvim-web-devicons']
      end
    end,
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      local ai = require('mini.ai')
      ai.setup({
        n_lines = 500,
        custom_textobjects = {
          ['%'] = '',
          s = ai.gen_spec.treesitter({ -- code block
            a = { '@block.outer', '@conditional.outer', '@loop.outer' },
            i = { '@block.inner', '@conditional.inner', '@loop.inner' },
          }),
          f = ai.gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }), -- function
          i = require('mini.extra').gen_ai_spec.indent(),
          g = require('mini.extra').gen_ai_spec.buffer(),
        },
      })

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup({
        mappings = {
          add = 'S', -- Add surrounding in Normal and Visual modes
          delete = 'ds', -- Delete surrounding

          -- disable these so flash search is fast
          find = '', -- disables 'sf'
          find_left = '', -- disables 'sF'
          highlight = '', -- disables 'sh'
          replace = '', -- disables 'sr'
          update_n_lines = '', -- disables 'sn'

          -- find = 'Sf', -- Find surrounding (to the right)
          -- find_left = 'SF', -- Find surrounding (to the left)
          -- highlight = 'Sh', -- Highlight surrounding
          -- replace = 'Sr', -- Replace surrounding
          -- update_n_lines = 'Sn', -- Update `n_lines`
          --
          -- suffix_last = 'l', -- Suffix to search with "prev" method
          -- suffix_next = 'n', -- Suffix to search with "next" method
        },
      })

      require('mini.pairs').setup({
        mappings = {
          ['('] = { action = 'open', pair = '()', neigh_pattern = '[^\\][%s)}%]]' },
          ['['] = { action = 'open', pair = '[]', neigh_pattern = '[^\\][%s)}%]]' },
          ['{'] = { action = 'open', pair = '{}', neigh_pattern = '[^\\][%s)}%]]' },
          ['`'] = { neigh_pattern = '[^%a%d\\%-``][%s)}%]]' },
          ['"'] = { neigh_pattern = '[^%a%d\\%-"\'`][%s)}%]]' },
          ["'"] = { neigh_pattern = '[^%a%d\\%-"\'`][%s)}%]]' },
        },
      })

      vim.g.minipairs_disable = true
      if Snacks then
        Snacks.toggle({
          name = 'mini.pairs',
          get = function() return not vim.g.minipairs_disable end,
          set = function(state) vim.g.minipairs_disable = not state end,
        }):map('<leader>vp')
      end

      require('mini.icons').setup()

      require('mini.trailspace').setup()
      vim.api.nvim_create_user_command('StripWhiteSpace', MiniTrailspace.trim, {})

      if Snacks then
        Snacks.toggle({
          name = 'mini.trailspace',
          get = function() return not vim.g.minitrailspace_disable end,
          set = function(state) vim.g.minitrailspace_disable = not state end,
        }):map('<leader>vW')
      end

      -- require('mini.tabline').setup()

      -- -- Simple and easy statusline.
      -- --  You could remove this setup call if you don't like it,
      -- --  and try some other statusline plugin
      -- local statusline = require 'mini.statusline'
      -- -- set use_icons to true if you have a Nerd Font
      -- statusline.setup { use_icons = vim.g.have_nerd_font }
      --
      -- -- You can configure sections in the statusline by overriding their
      -- -- default behavior. For example, here we set the section for
      -- -- cursor location to LINE:COLUMN
      -- ---@diagnostic disable-next-line: duplicate-set-field
      -- statusline.section_location = function()
      --   return '%2l:%-2v'
      -- end

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
