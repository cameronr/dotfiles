return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    enabled = false,
    cmd = 'RenderMarkdown',

    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      file_types = { 'markdown', 'Avante' },
    },
  },
  {
    'OXY2DEV/markview.nvim',
    cmd = 'Markview',
    ft = { 'markdown', 'opencode_output' },
    opts = {
      preview = {
        enable = true,
        filetypes = { 'md', 'rmd', 'quarto', 'opencode_output', 'markdown' },
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
          get = function() return require('markview').state.buffer_states[vim.api.nvim_get_current_buf()].enable end,
          set = function(_) vim.cmd('Markview toggle') end,
        }):map('<leader>vm')
      end
    end,
  },
}
