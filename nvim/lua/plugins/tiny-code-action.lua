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
            backdrop = true,
            width = 0.7,
            min_width = 80,
            height = 0.7,
            min_height = 3,
            box = 'vertical',
            border = 'rounded',
            title = '{title}',
            title_pos = 'center',
            { win = 'input', height = 1, border = 'bottom' },
            { win = 'list', border = 'none' },
            { win = 'preview', title = '{preview}', height = 0.7, border = 'top' },
          },
        },
        win = {
          input = {
            keys = {
              -- disable multiselect
              ['<Tab>'] = { 'list_down', mode = { 'i', 'n' } },
              ['<S-Tab>'] = { 'list_up', mode = { 'i', 'n' } },
            },
          },
        },
      },
    },
  },
}
