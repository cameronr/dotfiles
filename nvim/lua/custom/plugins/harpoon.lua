return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  keys = {
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
    {
      '<leader>1',
      function() require('harpoon'):list():select(1) end,
      desc = 'Harpoon 1',
    },
    {
      '<leader>2',
      function() require('harpoon'):list():select(2) end,
      desc = 'Harpoon 2',
    },
    {
      '<leader>3',
      function() require('harpoon'):list():select(3) end,
      desc = 'Harpoon 3',
    },
    {
      '<leader>4',
      function() require('harpoon'):list():select(4) end,
      desc = 'Harpoon 4',
    },
    {
      '<leader>5',
      function() require('harpoon'):list():select(5) end,
      desc = 'Harpoon 5',
    },
  },
  opts = {},
}
