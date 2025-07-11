---@module 'lazy'
---@type LazySpec
return {
  'andymass/vim-matchup',
  -- enabled = false,
  event = { 'BufReadPost', 'BufNewFile' },
  config = function()
    -- may set any options here
    vim.g.matchup_matchparen_offscreen = {}
  end,
}
