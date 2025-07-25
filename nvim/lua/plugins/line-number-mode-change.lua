---@module 'lazy'
---@type LazySpec
return {
  'cameronr/line-number-change-mode.nvim',
  branch = 'cursorline',
  enabled = false,
  -- dev = true,
  event = { 'ModeChanged', 'WinEnter', 'WinLeave' },
  opts = function(_, opts)
    if not vim.g.colors_name or not vim.g.colors_name:match('^tokyonight') then return { mode = {} } end

    local palette = require('tokyonight.colors').setup()
    if palette == nil then return { mode = {} } end

    return vim.tbl_deep_extend('force', opts or {}, {
      -- debug = true,
      -- hide_inactive_cursorline = true,

      mode = {
        n = {
          fg = palette.orange,
          -- fg = palette.blue,
          bold = true,
        },
        i = {
          fg = palette.green,
          bold = true,
        },
        R = {
          fg = palette.red,
          bold = true,
        },
        v = {
          fg = palette.purple,
          bold = true,
        },
        V = {
          fg = palette.purple,
          bold = true,
        },
        c = {
          fg = palette.yellow,
          bold = true,
        },
        s = {
          fg = palette.blue2,
          bold = true,
        },
      },
    })
  end,
}
