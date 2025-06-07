return {
  'rachartier/tiny-code-action.nvim',
  -- enabled = false,
  -- dev = true,
  event = 'LspAttach',
  opts = {
    backend = 'delta',
    picker = {
      'snacks',
      opts = {
        layout = {
          preview = true,
          layout = {
            backdrop = false,
            width = 0.7,
            min_width = 80,
            height = 0.7,
            min_height = 3,
            box = 'vertical',
            border = 'rounded',
            title = '{title}',
            title_pos = 'center',
            { win = 'preview', title = '{preview}', height = 0.6, border = 'bottom' },
            { win = 'list', border = 'none' },
            { win = 'input', height = 1, border = 'top' },
          },
        },
      },
    },
  },
}
