---@module 'lazy'
---@type LazySpec
return {
  'nvim-treesitter/nvim-treesitter-context',
  event = { 'BufReadPre', 'BufNewFile' },
  opts = function(_, opts)
    if Snacks then
      local ts_context = require('treesitter-context')
      Snacks.toggle({
        name = 'treesitter context',
        get = function() return ts_context.enabled() end,
        set = function(state)
          if state then
            ts_context.enable()
          else
            ts_context.disable()
          end
        end,
      }):map('<leader>vo')
    end

    return vim.tbl_deep_extend('force', opts or {}, {
      max_lines = 10,
      multiline_threshold = 3,
    })
  end,
}
