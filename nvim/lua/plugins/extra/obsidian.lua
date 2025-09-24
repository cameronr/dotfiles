return {
  {
    'obsidian-nvim/obsidian.nvim',
    version = '*', -- recommended, use latest release instead of latest commit
    ft = 'markdown',
    cmd = 'Obsidian',
    -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
    -- event = {
    --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
    --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
    --   -- refer to `:h file-pattern` for more examples
    --   "BufReadPre path/to/my-vault/*.md",
    --   "BufNewFile path/to/my-vault/*.md",
    -- },

    keys = {
      { '<leader>so', '<cmd>Obsidian search<CR>', desc = 'Obsidian search' },
      { '<leader>to', '<cmd>Obsidian search<CR>', desc = 'Obsidian search' },
      { '<leader>tn', '<cmd>Obsidian new<CR>', desc = 'Obsidian new' },
    },

    ---@module 'obsidian'
    ---@type obsidian.config.ClientOpts
    ---@diagnostic disable-next-line: missing-fields
    opts = {
      workspaces = {
        {
          name = 'personal',
          path = '~/Library/Mobile Documents/iCloud~md~obsidian/Documents/personal/',
        },
      },
      ---@diagnostic disable-next-line: missing-fields
      completion = {
        nvim_cmp = false,
        blink = true,
      },

      ---@diagnostic disable-next-line: missing-fields
      picker = {
        name = 'snacks.pick',
      },

      ui = {
        ignore_conceal_warn = true,
      },
      legacy_commands = false,
    },
    init = function()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'markdown',
        callback = function()
          vim.keymap.set('i', '<CR>', function()
            local line = vim.api.nvim_get_current_line()
            local checkbox_pat = '^%s*%- %[[ xX]?%]'
            local bullet_pat = '^%s*%-'

            if line:match(checkbox_pat) then
              return '<CR>- [ ] '
            elseif line:match(bullet_pat) then
              return '<CR>- '
            else
              return '<CR>'
            end
          end, { buffer = true, expr = true })

          local function move_checked_item()
            local buf = vim.api.nvim_get_current_buf()
            local cursor_pos = vim.api.nvim_win_get_cursor(0)
            local current_line_num = cursor_pos[1] - 1

            -- Get the current line content
            local current_line = vim.api.nvim_buf_get_lines(buf, current_line_num, current_line_num + 1, false)[1]

            -- Check if current line is checked
            if not current_line:match('^%s*[%-%*%+]%s*%[%s*[xX]%s*%]') then return end

            -- Find first empty line or checked line below current position
            local total_lines = vim.api.nvim_buf_line_count(buf)
            local target_line = nil

            for line_num = current_line_num + 1, total_lines do
              local line = vim.api.nvim_buf_get_lines(buf, line_num, line_num + 1, false)[1]
              if not line or line == '' or line:match('^%s*[%-%*%+]%s*%[%s*[xX]%s*%]') then
                target_line = line_num
                break
              end
            end

            -- If no target found, move to end of buffer
            if not target_line then target_line = total_lines + 1 end

            -- Cut current line and insert BEFORE target (to be at top of checked items)
            vim.api.nvim_buf_set_lines(buf, current_line_num, current_line_num + 1, false, {})
            vim.api.nvim_buf_set_lines(buf, target_line - 1, target_line - 1, false, { current_line })

            -- adjust cursor so it doesn't move down if checking and then rechecking in the completed section
            if target_line == cursor_pos[1] then vim.api.nvim_win_set_cursor(0, { target_line, cursor_pos[2] }) end
          end

          -- Create a command to call the function
          vim.api.nvim_create_user_command('MoveChecked', move_checked_item, {
            desc = 'Sort checked markdown items to the bottom of the current paragraph',
          })

          local function dial_and_move(increment)
            require('dial.map').manipulate((increment and 'increment' or 'decrement'), 'normal', 'markdown')
            move_checked_item()
          end

          vim.keymap.set('n', '<C-a>', function() dial_and_move(true) end, { buffer = true })
          vim.keymap.set('n', '<C-x>', function() dial_and_move(false) end, { buffer = true })
          vim.keymap.set('v', '<C-a>', function() dial_and_move(true) end, { buffer = true })
          vim.keymap.set('v', '<C-x>', function() dial_and_move(false) end, { buffer = true })
        end,
      })
    end,
  },
}
