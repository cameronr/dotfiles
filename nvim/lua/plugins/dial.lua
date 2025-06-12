return {
  'monaqa/dial.nvim',
  keys = {
    { '<C-a>', function() require('dial.map').manipulate('increment', 'normal') end, mode = { 'n', 'x' }, desc = 'increment' },
    { 'gs', function() require('dial.map').manipulate('increment', 'normal') end, mode = { 'n', 'x' }, desc = 'increment' },
    { '<C-x>', function() require('dial.map').manipulate('decrement', 'normal') end, mode = { 'n', 'x' }, desc = 'decrement' },
  },
  config = function()
    local augend = require('dial.augend')
    require('dial.config').augends:register_group({
      default = {
        augend.integer.alias.decimal,
        augend.integer.alias.hex,
        augend.date.alias['%Y/%m/%d'],
        augend.constant.alias.bool, -- boolean value (true <-> false)
        augend.hexcolor.new({ case = 'prefer_lower' }),
      },
    })
  end,
}
