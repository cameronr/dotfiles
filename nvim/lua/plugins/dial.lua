---language server seems confused by dial's returns so disabling this rule
---@diagnostic disable: redundant-return-value

---@module 'lazy'
---@type LazySpec
return {
  'monaqa/dial.nvim',
  keys = {
    { '<C-a>', function() require('dial.map').manipulate('increment', 'normal') end, mode = { 'n', 'x' }, desc = 'increment' },
    { 'gs', function() require('dial.map').manipulate('increment', 'normal') end, mode = { 'n', 'x' }, desc = 'increment' },
    { '<C-x>', function() require('dial.map').manipulate('decrement', 'normal') end, mode = { 'n', 'x' }, desc = 'decrement' },
  },
  config = function()
    local augend = require('dial.augend')

    local saved_start_pos

    -- Markdown checkboxes
    local checkbox_line_augend = augend.user.new({

      find = function(line, _)
        local start, _, _ = line:find('%- %[([%sx%-!%?/><%w])%]')
        if start then
          -- need to save where the start position is to restore the cursor
          saved_start_pos = start - 1
          -- The checkbox char is at start+3 (after '- [')
          return { from = start + 3, to = start + 3 }
        end
        return nil
      end,

      add = function(text, addend, cursor)
        if text == ' ' then
          return { text = 'x', cursor = cursor - 3 - saved_start_pos }
        elseif text == 'x' then
          return { text = ' ', cursor = cursor - 3 - saved_start_pos }
        else
          if addend > 0 then
            return { text = 'x', cursor = cursor - 3 - saved_start_pos }
          else
            return { text = ' ', cursor = cursor - 3 - saved_start_pos }
          end
        end
      end,
    })

    local default = {
      augend.integer.alias.decimal,
      augend.integer.alias.hex,
      augend.date.alias['%Y/%m/%d'],
      augend.constant.alias.bool, -- boolean value (true <-> false)
      augend.hexcolor.new({ case = 'prefer_lower' }),
      augend.constant.new({ -- useful for yaml
        elements = { 'True', 'False' },
        word = true, -- ensures only whole words are matched
        cyclic = true,
      }),
    }

    require('dial.config').augends:register_group({
      default = default,
      markdown = vim.list_extend({ checkbox_line_augend }, default),
    })
  end,
}
