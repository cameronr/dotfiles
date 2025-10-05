return {
  {
    'sudo-tee/opencode.nvim',
    cond = function() return vim.fn.executable('opencode') == 1 end,
    cmd = 'Opencode',
    keys = {
      { '<leader>ao', '<cmd>Opencode<CR>', desc = 'Opencode' },
    },
    opts = {
      preferred_picker = 'snacks',
      keymap = {
        window = {
          submit = '<c-s>',
          submit_insert = '<c-s>',
          close = false,
          prev_prompt_history = false,
          next_prompt_history = false,
          toggle_pane = false,
        },
      },
      ui = {
        input_width = 0.42,
        input_height = 0.21,
        input = {
          text = {
            wrap = true, -- Wraps text inside input window
          },
        },
      },
    },
    init = function()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'opencode', -- trigger only for this filetype
        callback = function(args)
          local map = require('opencode.keymap').buf_keymap
          local nav_history = require('opencode.ui.util').navigate_history
          local api = require('opencode.api')

          local prev_prompt_history = '<UP>'
          local next_prompt_history = '<DOWN>'
          local toggle_pane = '<tab>'
          map(prev_prompt_history, nav_history(prev_prompt_history, 'prev'), args.buf, { 'n' })
          map(next_prompt_history, nav_history(next_prompt_history, 'next'), args.buf, { 'n' })
          map(toggle_pane, api.toggle_pane, args.buf, { 'n' })
        end,
      })
    end,
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    optional = true,
    opts = {
      anti_conceal = { enabled = false },
      file_types = { 'markdown', 'opencode_output' },
    },
    -- ft = { 'markdown', 'Avante', 'copilot-chat', 'opencode_output' },
  },
  {
    'nvim-lualine/lualine.nvim',
    optional = true,
    opts = function(_, opts)
      opts.options.ignore_focus = opts.options.ignore_focus or {}
      table.insert(opts.options.ignore_focus, 'opencode')
      table.insert(opts.options.ignore_focus, 'opencode_output')
    end,
  },
}
