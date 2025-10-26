return {
  -- {
  --   'MeanderingProgrammer/render-markdown.nvim',
  --   enabled = true,
  --   cmd = 'RenderMarkdown',
  --
  --   ---@module 'render-markdown'
  --   ---@type render.md.UserConfig
  --   opts = {
  --     file_types = { 'opencode_output' },
  --   },
  -- },
  {
    'OXY2DEV/markview.nvim',
    lazy = false,
    -- add lazy loading back in once this release goes live:
    -- https://github.com/OXY2DEV/markview.nvim/pull/401
    -- enabled = false,
    cmd = 'Markview',
    ft = { 'markdown' },
    opts = {
      preview = {
        enable = true,
        filetypes = { 'md', 'rmd', 'quarto', 'markdown' },
        ignore_buftypes = {},
      },
      markdown = {
        headings = {
          heading_1 = {
            sign = false,
          },
          heading_2 = {
            sign = false,
          },
        },
        code_blocks = {
          sign = false,
        },
      },
    },
    config = function(_, opts)
      require('markview').setup(opts)
      require('markview.highlights').setup()
      if Snacks then
        Snacks.toggle({
          name = 'Markview',
          get = function()
            local state = require('markview').state.buffer_states[vim.api.nvim_get_current_buf()]
            return state and state.enable or false
          end,
          set = function(_) vim.cmd('Markview toggle') end,
        }):map('<leader>vm')
      end
    end,
  },
}
