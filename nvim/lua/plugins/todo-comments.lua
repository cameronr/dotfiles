return {
  'folke/todo-comments.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  cmd = { 'TodoTrouble', 'TodoTelescope' },
  opts = {
    keywords = {
      TODO = { icon = '󰄱' },
      HACK = { icon = '󰣈' },
      WARN = { icon = '󰉀' },
      PERF = { icon = '󱙷' },
      NOTE = { icon = '' },
      TEST = { icon = '󰙨' },
    },
  },
  keys = {
    { ']t', function() require('todo-comments').jump_next() end, desc = 'Next todo' },
    { '[t', function() require('todo-comments').jump_prev() end, desc = 'Previous todo' },
    {
      '<leader>st',
      function()
        if vim.g.picker_engine == 'fzf' then
          require('todo-comments.fzf').todo()
        elseif vim.g.picker_engine == 'snack' then
          Snacks.picker.todo_comments()
        else
          vim.cmd('TodoTelescope')
        end
      end,
      desc = 'Todo',
    },
  },
}
