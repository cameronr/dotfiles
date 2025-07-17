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
    },
    init = function()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'markdown',
        callback = function()
          vim.keymap.set('i', '<CR>', function()
            local line = vim.api.nvim_get_current_line()
            local checkbox_pat = '^%s*%- %[[ xX]?%] '
            if line:match(checkbox_pat) then
              -- Let Vim handle indentation, just add the checkbox
              return '<CR>- [ ] '
            else
              return '<CR>'
            end
          end, { buffer = true, expr = true })
          vim.keymap.set('n', '<C-a>', require('dial.map').inc_normal('markdown'), { buffer = true })
          vim.keymap.set('n', '<C-x>', require('dial.map').dec_normal('markdown'), { buffer = true })
          vim.keymap.set('v', '<C-a>', require('dial.map').inc_visual('markdown'), { buffer = true })
          vim.keymap.set('v', '<C-x>', require('dial.map').dec_visual('markdown'), { buffer = true })
        end,
      })
    end,
  },
}
