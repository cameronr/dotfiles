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
