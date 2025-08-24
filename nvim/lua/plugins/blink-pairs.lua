return {
  'saghen/blink.pairs',
  event = { 'BufReadPre', 'BufNewFile' },
  version = '*', -- (recommended) only required with prebuilt binaries

  -- download prebuilt binaries from github releases
  dependencies = 'saghen/blink.download',

  --- @module 'blink.pairs'
  --- @type blink.pairs.Config
  opts = {

    ---@diagnostic disable-next-line: missing-fields
    mappings = {
      enabled = false,
    },
    highlights = {
      groups = {
        'RainbowDelimiterRed',
        --  'RainbowDelimiterOrange',
        'RainbowDelimiterYellow',
        'RainbowDelimiterGreen',
        'RainbowDelimiterBlue',
        'RainbowDelimiterViolet',
        'RainbowDelimiterCyan',
      },
    },
  },
}
