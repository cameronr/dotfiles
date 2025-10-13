local function load_opencode(callback)
  pcall(require, 'opencode')
  local tries = 0
  local function tick()
    if vim.fn.exists(':Opencode') == 2 then
      if callback then callback() end
      return
    end
    tries = tries + 1
    if tries > 30 then
      vim.notify('Failed to load Opencode', vim.log.levels.WARN)
      return
    end
    vim.defer_fn(tick, 100)
  end
  tick()
end

return {
  {
    'sudo-tee/opencode.nvim',
    -- dev = true,
    cond = function() return vim.fn.executable('opencode') == 1 end,
    cmd = 'Opencode',
    keys = {
      {
        '<leader>aa',
        function()
          load_opencode(function() vim.cmd('Opencode') end)
        end,
        desc = 'Opencode toggle',
      },
    },
    opts = {
      preferred_picker = 'snacks',
      keymap_prefix = '<leader>a',
      keymap = {
        editor = {
          -- ['<leader>aO'] = { 'open_output' },
          ['<leader>am'] = { 'switch_mode' },
          ['<leader>aR'] = { function() require('opencode.ui.ui').render_output(true) end },
          ['<leader>aa'] = { 'toggle' },
        },
        output_window = {
          ['<esc>'] = false,
        },
        input_window = {
          -- submit = '<c-s>',
          -- submit_insert = '<c-s>',
          -- close = false,
          -- focus_input = false,
          -- prev_prompt_history = false,
          -- next_prompt_history = false,
          -- toggle_pane = false,

          ['<esc>'] = false,
          ['<c-i>'] = false,
          ['<up>'] = false,
          ['<down>'] = false,
          ['<cr>'] = false,
          ['<c-s>'] = {
            function()
              vim.cmd('stopinsert')
              require('opencode.api').submit_input_prompt()
            end,
            mode = { 'i', 'n' },
          },
          ['<c-up>'] = { 'prev_prompt_history', mode = { 'i', 'n' } },
          ['<c-down>'] = { 'next_prompt_history', mode = { 'i', 'n' } },
        },
      },
      ui = {
        window_width = 0.42,
        input_height = 0.21,
        loading_animation = {
          frames = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
        },
        input = {
          text = {
            wrap = true, -- Wraps text inside input window
          },
        },
      },
      debug = {
        enabled = true,
        capture_streamed_events = true,
      },
    },
    -- config = function(_, opts)
    --   local ok, opencode = pcall(require, 'opencode')
    --   if not ok then return end
    --   opencode.setup(opts)
    --
    --   -- local map = vim.keymap.set
    --   -- local api = require('opencode.api')
    --   -- map('n', '<leader>aa', api.switch_mode, { desc = 'Opencode: toggle agent/build' })
    --   -- map('n', '<leader>as', api.select_session, { desc = 'Opencode: select session' })
    --   -- map('n', '<leader>ap', api.configure_provider, { desc = 'Opencode: configure provider' })
    --   -- map('n', '<leader>aR', function() require('opencode.ui.ui').render_output(true) end, { desc = 'Opencode full reload' })
    -- end,

    vim.api.nvim_create_user_command('OpencodeReplay', function()
      vim.opt.runtimepath:append('.')
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.notify = function(msg, level, opts)
        level = level or vim.log.levels.INFO
        opts = opts or {}
        vim.api.nvim_echo({ { msg } }, true, opts)
      end
      require('tests.manual.streaming_renderer_replay').start({ set_statuscolumn = false })
    end, {}),
  },
  {
    'nvim-lualine/lualine.nvim',
    optional = true,
    opts = function(_, opts)
      opts.options.ignore_focus = opts.options.ignore_focus or {}
      table.insert(opts.options.ignore_focus, 'opencode')
      table.insert(opts.options.ignore_focus, 'opencode_output')
    end,
  },
  {
    'OXY2DEV/markview.nvim',
    optional = true,
    ft = { 'opencode_output' },
    opts = {
      preview = {
        filetypes = { 'opencode_output' },
      },
    },
    opts_extend = { 'preview.filetypes' },
  },
  {
    'luukvbaal/statuscol.nvim',
    event = { 'BufNewFile', 'BufReadPost' },
    opts = {
      ft_ignore = { 'opencode_output' },
    },
    opts_extend = { 'ft_ignore' },
  },
}
