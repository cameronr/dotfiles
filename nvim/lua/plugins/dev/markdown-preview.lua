---@module 'lazy'
---@type LazySpec
return {
  'iamcco/markdown-preview.nvim',
  cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
  build = 'cd app && yarn install',
  cond = function() return vim.fn.executable('yarn') == 1 end,
  init = function() vim.g.mkdp_filetypes = { 'markdown' } end,
}
