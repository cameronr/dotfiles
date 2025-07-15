---@module 'lazy'
---@type LazySpec
return {
  'stevearc/oil.nvim',

  cmd = 'Oil',
  keys = {
    {
      '<Bslash><Bslash>',
      function() require('oil').toggle_float() end,
      desc = 'Oil',
    },
  },
  opts = {
    default_file_explorer = true,
    delete_to_trash = true,
    skip_confirm_for_simple_edits = false,
    view_options = {
      show_hidden = true,
      natural_order = true,
      is_always_hidden = function(name, _) return name == '..' or name == '.git' end,
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
      ['<C-v>'] = { 'actions.select', opts = { vertical = true }, desc = 'Open the entry in a vertical split' },
      ['<C-s>'] = { function() vim.cmd.write() end, desc = 'Write changes' },
      ['<C-c>'] = false,

      -- don't interfere with window switching keys
      ['<C-h>'] = false,
      ['<C-l>'] = false,

      ['q'] = 'actions.close',
      ['<Esc>'] = 'actions.close',
      ['\\'] = 'actions.parent',
    },
  },
}
