return {
  { -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    opts = {
      indent = {
        char = '│',
        tab_char = '│',
      },
      scope = {
        show_start = false,
      },
    },
    keys = {
      {
        '<leader>vi',
        '<cmd>IBLToggleScope<cr>',
        desc = 'Toggle scope',
      },
    },
  },
}
