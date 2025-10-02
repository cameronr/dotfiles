return {
  ---@module 'lazy'
  ---@type LazySpec
  { -- Collection of various small independent plugins/modules
    'nvim-mini/mini.nvim',
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
          c = ai.gen_spec.treesitter({ a = '@call.outer', i = '@call.inner' }),
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
          delete = 'dS', -- Delete surrounding

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

      -- mini pairs config with open pulled from LazyVim
      local pairs = require('mini.pairs')
      local pairs_opts = {
        modes = { insert = true, command = true, terminal = false },

        mappings = {
          ['('] = { action = 'open', pair = '()', neigh_pattern = '[^\\][%s)}%]]' },
          ['['] = { action = 'open', pair = '[]', neigh_pattern = '[^\\][%s)}%]]' },
          ['{'] = { action = 'open', pair = '{}', neigh_pattern = '[^\\][%s)}%]]' },
          ['`'] = { neigh_pattern = '[^%a%d\\%-``][%s)}%]]' },
          ['"'] = { neigh_pattern = '[^%a%d\\%-"\'`][%s)}%]]' },
          ["'"] = { neigh_pattern = '[^%a%d\\%-"\'`][%s)}%]]' },
        },

        -- skip autopair when next character is one of these
        -- skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
        -- skip autopair when the cursor is inside these treesitter nodes
        skip_ts = { 'string' },
        -- skip autopair when next character is closing pair
        -- and there are more closing pairs than opening pairs
        skip_unbalanced = true,
        -- better deal with markdown code blocks
        markdown = true,
      }
      pairs.setup(pairs_opts)
      local open = pairs.open
      ---@diagnostic disable-next-line: duplicate-set-field
      pairs.open = function(pair, neigh_pattern)
        if vim.fn.getcmdline() ~= '' then return open(pair, neigh_pattern) end
        local o, c = pair:sub(1, 1), pair:sub(2, 2)
        local line = vim.api.nvim_get_current_line()
        local cursor = vim.api.nvim_win_get_cursor(0)
        local next = line:sub(cursor[2] + 1, cursor[2] + 1)
        local before = line:sub(1, cursor[2])
        if pairs_opts.markdown and o == '`' and vim.bo.filetype == 'markdown' and before:match('^%s*``') then
          return '`\n```' .. vim.api.nvim_replace_termcodes('<up>', true, true, true)
        end
        if pairs_opts.skip_next and next ~= '' and next:match(pairs_opts.skip_next) then return o end
        if pairs_opts.skip_ts and #pairs_opts.skip_ts > 0 then
          local ok, captures = pcall(vim.treesitter.get_captures_at_pos, 0, cursor[1] - 1, math.max(cursor[2] - 1, 0))
          for _, capture in ipairs(ok and captures or {}) do
            if vim.tbl_contains(pairs_opts.skip_ts, capture.capture) then return o end
          end
        end
        if pairs_opts.skip_unbalanced and next == c and c ~= o then
          local _, count_open = line:gsub(vim.pesc(pair:sub(1, 1)), '')
          local _, count_close = line:gsub(vim.pesc(pair:sub(2, 2)), '')
          if count_close > count_open then return o end
        end
        return open(pair, neigh_pattern)
      end

      -- -- vim.g.minipairs_disable = true
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

      -- require('mini.notify').setup({
      --   content = {
      --     format = function(notif)
      --       local str = MiniNotify.default_format(notif)
      --       local result = {}
      --       for line in str:gmatch('([^\n]*)\n?') do
      --         if line ~= '' then
      --           table.insert(result, ' ' .. line .. ' ')
      --         else
      --           table.insert(result, line)
      --         end
      --       end
      --       if result[#result] == '' then table.remove(result) end
      --       return table.concat(result, '\n')
      --     end,
      --   },
      --   window = {
      --     config = {
      --       border = 'rounded',
      --     },
      --     winblend = 0,
      --   },
      -- })
      -- vim.keymap.set('n', '<leader>sp', function() MiniNotify.show_history() end, { desc = 'Notifications' })
      -- vim.keymap.set('n', '<leader>wp', function() MiniNotify.clear() end, { desc = 'Clear notifications' })

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
