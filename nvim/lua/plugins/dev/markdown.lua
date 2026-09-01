return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    lazy = false,
    cmd = 'RenderMarkdown',
    ft = { 'markdown', 'opencode_output' },

    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      file_types = { 'markdown', 'opencode_output' },
      -- heading = { icons = false },

      -- disable tables to use markdown-table-wrap below
      -- pipe_table = { enabled = false },
      sign = { enabled = false },
    },
    opts_extend = { 'file_types' },
    config = function(_, opts)
      require('render-markdown').setup(opts)
      if Snacks then
        Snacks.toggle({
          name = 'RenderMarkdown',
          get = function() return require('render-markdown').get() end,
          set = function(_) vim.cmd('RenderMarkdown toggle') end,
        }):map('<leader>vm')
      end
    end,
  },
  {
    'ice345/markdown-table-wrap.nvim',
    -- ft = { 'markdown', 'opencode_output' },
    ft = { 'markdown' },
    opts = {
      inline_wrap_scope = 'always',
      -- extra_filetypes = { 'opencode_output' },
    },
    -- opts_extend = { 'extra_filetypes' },
  },
}
