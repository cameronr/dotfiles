return {
  'sethen/line-number-change-mode.nvim',
  opts = function()
    local palette = require('tokyonight.colors').setup()
    if palette == nil then return nil end

    local opts = {
      mode = {
        i = {
          fg = palette.green,
          bold = true,
        },
        n = {
          fg = palette.orange,
          -- fg = palette.blue,
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
      },
    }
    return opts
  end,
}
