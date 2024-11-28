return {
  { -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- enabled = false,
    event = { 'BufReadPre', 'BufNewFile' },
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    opts = function()
      Snacks.toggle({
        name = 'indention guides',
        get = function() return require('ibl.config').get_config(0).enabled end,
        set = function(state) require('ibl').setup_buffer(0, { enabled = state }) end,
      }):map('<leader>vi')

      return {
        indent = {
          char = '│',
          tab_char = '│',
        },
        scope = {
          show_start = false,
        },
      }
    end,
  },
}
