return {
  'andrewferrier/debugprint.nvim',
  keys = {
    { 'g?p', desc = 'Plain debug below current line' },
    { 'g?P', desc = 'Plain debug above current line' },
    { 'g?v', desc = 'Variable debug below current line' },
    { 'g?V', desc = 'Variable debug above current line' },
  },
  cmd = { 'DeleteDebugPrints', 'ToggleCommentDebugPrints' },
  opts = {},
}
