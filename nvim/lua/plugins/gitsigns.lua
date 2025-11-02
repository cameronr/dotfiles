-- Here is a more advanced example where we pass configuration
-- options to `gitsigns.nvim`. This is equivalent to the following Lua:
--    require('gitsigns').setup({ ... })
--
-- See `:help gitsigns` to understand what the configuration keys do
return {
  ---@module 'lazy'
  ---@type LazySpec
  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },

    opts = {
      current_line_blame_formatter = '-> <author>, <author_time:%R> - <summary>',
      preview_config = {
        border = 'rounded',
      },
      on_attach = function(bufnr)
        local gitsigns = require('gitsigns')

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']h', function()
          if vim.wo.diff then
            vim.cmd.normal({ ']c', bang = true })
          else
            gitsigns.nav_hunk('next')
          end
        end, { desc = 'Jump to next git hunk' })

        map('n', '[h', function()
          if vim.wo.diff then
            vim.cmd.normal({ '[c', bang = true })
          else
            gitsigns.nav_hunk('prev')
          end
        end, { desc = 'Jump to previous git hunk' })

        -- Actions
        -- visual mode
        map(
          'v',
          '<leader>hs',
          function() gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end,
          { desc = 'stage git hunk' }
        )
        map(
          'v',
          '<leader>hr',
          function() gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end,
          { desc = 'reset git hunk' }
        )
        -- normal mode
        map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'git stage hunk' })
        map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'git reset hunk' })
        map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'git Stage buffer' })
        map('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'git Reset buffer' })
        map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'git preview hunk' })
        -- map('n', '<leader>hb', function() gitsigns.blame_line({ full = true }) end, { desc = 'git blame line' })
        map('n', '<leader>hB', function() gitsigns.blame() end, { desc = 'git blame' })
        map('n', '<leader>he', gitsigns.preview_hunk_inline, { desc = 'git show deleted' })
        -- Toggles

        if Snacks then
          local config = require('gitsigns.config').config
          Snacks.toggle({
            name = 'git inline blame line',
            get = function() return config.current_line_blame end,
            set = function(state) gitsigns.toggle_current_line_blame(state) end,
          }):map('<leader>ht')

          Snacks.toggle({
            name = 'git inline diff',
            get = function() return config.linehl and config.word_diff end,
            set = function(state)
              gitsigns.toggle_linehl(state)
              gitsigns.toggle_word_diff(state)
            end,
          }):map('<leader>hi')
        else
          map('n', '<leader>ht', gitsigns.toggle_current_line_blame, { desc = 'git toggle show blame line' })
          map('n', '<leader>hi', function()
            gitsigns.toggle_linehl()
            gitsigns.toggle_word_diff()
          end, { desc = 'git toggle inline diff' })
        end

        -- Text object
        map({ 'o', 'x' }, 'ih', gitsigns.select_hunk)
        map({ 'o', 'x' }, 'ah', gitsigns.select_hunk)
      end,
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
