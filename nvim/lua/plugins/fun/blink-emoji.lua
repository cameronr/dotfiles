return {
  ---@module "lazy"
  ---@type LazySpec
  {
    'saghen/blink.cmp',
    optional = true,
    dependencies = {
      'moyiz/blink-emoji.nvim',
    },
    opts = {
      sources = {
        default = {
          'emoji',
        },
        providers = {
          emoji = {
            module = 'blink-emoji',
            name = '😃',
            score_offset = 15, -- Tune by preference
            max_items = 10,
            should_show_items = function()
              return vim.tbl_contains(
                -- Enable emoji completion only for git commits and markdown.
                -- By default, enabled for all file-types.
                { 'gitcommit', 'markdown' },
                vim.o.filetype
              )
            end,
            opts = {
              insert = true, -- Insert emoji (default) or complete its name
              ---@type string|table|fun():table
              trigger = function() return { ':' } end,
            },
          },
        },
      },
    },
  },
}
