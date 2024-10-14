return {
  'cameronr/line-number-change-mode.nvim',
  -- event = 'VeryLazy',
  -- dev = true,
  opts = function()
    local palette = require('tokyonight.colors').setup()
    if palette == nil then return nil end

    local opts = {
      i = {
        fg = palette.green,
        -- fg = palette.mantle,
        bold = true,
      },
      n = {
        fg = palette.orange,
        -- fg = palette.mantle,
        bold = true,
      },
      R = {
        fg = palette.red,
        -- fg = palette.mantle,
        bold = true,
      },
      v = {
        fg = palette.purple,
        -- fg = palette.mantle,
        bold = true,
      },
      V = {
        fg = palette.purple,
        -- fg = palette.mantle,
        bold = true,
      },
      c = {
        fg = palette.yellow,
        -- fg = palette.mantle,
        bold = true,
      },
    }
    return opts
  end,
}
