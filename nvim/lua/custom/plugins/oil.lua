return {
  'stevearc/oil.nvim',

  keys = {
    { '<Bslash><Bslash>', '<cmd>lua require("oil").toggle_float()<CR>', desc = 'Oil popup' },
  },
  opts = {
    default_file_explorer = true,
    delete_to_trash = true,
    skip_confirm_for_simple_edits = false,
    view_options = {
      show_hidden = true,
      natural_order = true,
      is_always_hidden = function(name, _)
        return name == '..' or name == '.git'
      end,
    },
    float = {
      padding = 2,
      max_width = 90,
      max_height = 0,
    },
    win_options = {
      wrap = true,
      winblend = 0,
    },
    keymaps = {
      ['<C-c>'] = false,
      ['q'] = 'actions.close',
      ['<Esc>'] = 'actions.close',
    },
  },
  -- Optional dependencies
  dependencies = { 'nvim-tree/nvim-web-devicons' },
}
