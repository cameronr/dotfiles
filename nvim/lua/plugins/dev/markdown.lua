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
      ---@diagnostic disable-next-line: undefined-field
      require('render-markdown').setup(opts)
      if Snacks then
        Snacks.toggle({
          name = 'RenderMarkdown',
          ---@diagnostic disable-next-line: undefined-field
          get = function() return require('render-markdown').get() end,
          ---@diagnostic disable-next-line: call-non-callable
          set = function(_) vim.cmd('RenderMarkdown toggle') end,
        }):map('<leader>vm')
      end
    end,
  },
  {
    'davidmh/mdx.nvim',
  },
  {
    'ice345/markdown-table-wrap.nvim',
    -- ft = { 'markdown', 'opencode_output' },
    ft = { 'markdown', 'mdx' },
    opts = {
      inline_wrap_scope = 'always',
      extra_filetypes = { 'mdx' },
    },
    -- opts_extend = { 'extra_filetypes' },
    config = function(_, opts)
      require('markdown-table-wrap').setup(opts)
      if Snacks then
        Snacks.toggle({
          name = 'MarkdownTableAutoPreview',
          get = function()
            local bufnr = vim.api.nvim_get_current_buf()
            return not require('markdown-table-wrap').state.paused_buffers[bufnr]
          end,
          ---@diagnostic disable-next-line: call-non-callable
          set = function() vim.cmd('MarkdownTableToggleAutoPreview') end,
        }):map('<leader>vM')
      end
    end,
  },
}
