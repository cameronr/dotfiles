---@module 'lazy'
---@type LazySpec
return {
  'andymass/vim-matchup',
  -- disabled because of perf issues
  -- https://github.com/andymass/vim-matchup/issues/302
  cond = false,
  -- enabled = false,
  event = { 'BufReadPost', 'BufNewFile' },
  config = function()
    -- may set any options here
    vim.g.matchup_matchparen_offscreen = {}
  end,
}
