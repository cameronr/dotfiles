return {
  'cameronr/line-number-change-mode.nvim',
  branch = 'cursorline',
  -- dev = true,
  event = { 'ModeChanged', 'WinEnter', 'WinLeave' },
  -- enabled = false,
  opts = function()
    local palette = require('tokyonight.colors').setup()
    if palette == nil then return nil end

    local opts = {
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
    }
    return opts
  end,
}
