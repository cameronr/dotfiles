return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  keys = function()
    local keys = {
      {
        '<leader>oo',
        function()
          local harpoon = require('harpoon')
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end,
        desc = 'Harpoon open',
      },
      {
        '<leader>oa',
        function() require('harpoon'):list():add() end,
        desc = 'Harpoon file',
      },
      {
        '<leader>or',
        function() require('harpoon'):list():remove() end,
        desc = 'Unharpoon file',
      },
      {
        '<leader>oc',
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
        '<leader>o' .. i,
        function() require('harpoon'):list():replace_at(i) end,
        desc = 'Set buffer as ' .. i,
      })
    end

    return keys
  end,

  opts = {},
}
