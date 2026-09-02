---@module 'lazy'
---@type LazySpec
return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  keys = function()
    local keys = {
      {
        '<leader>Oo',
        function()
          local harpoon = require('harpoon')
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end,
        desc = 'Harpoon open',
      },
      {
        '<leader>Oa',
        function() require('harpoon'):list():add() end,
        desc = 'Harpoon file',
      },
      {
        '<leader>Or',
        function() require('harpoon'):list():remove() end,
        desc = 'Unharpoon file',
      },
      {
        '<leader>Oc',
        function() require('harpoon'):list():clear() end,
        desc = 'Unharpoon all files',
      },
    }

    for i = 1, 5 do
      table.insert(keys, {
        '<leader>' .. i,
        function() require('harpoon'):list():select(i) end,
        desc = 'Harpoon ' .. i,
      })

      table.insert(keys, {
        '<leader>O' .. i,
        function() require('harpoon'):list():replace_at(i) end,
        desc = 'Set buffer as ' .. i,
      })
    end

    return keys
  end,

  opts = {},
}
