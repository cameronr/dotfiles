---@module 'lazy'
---@type LazySpec
return {
  'benomahony/uv.nvim',
  ft = 'python',
  cond = function() return vim.fn.executable('uv') == 1 end,
  opts = {
    picker_integration = true,
  },
}
