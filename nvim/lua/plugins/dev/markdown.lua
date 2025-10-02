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
    },
    config = function()
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
