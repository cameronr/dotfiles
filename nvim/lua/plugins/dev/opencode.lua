return {
  {
    'sudo-tee/opencode.nvim',
    cond = function() return vim.fn.executable('opencode') == 1 end,
    cmd = 'Opencode',
    keys = {
      { '<leader>aa', desc = 'Opencode toggle', mode = { 'n', 'v' } },
      { '<leader>ai', desc = 'Opencode input', mode = { 'n', 'v' } },
      { '<leader>aI', desc = 'Opencode input new session', mode = { 'n', 'v' } },
    },
    opts = {
      default_mode = 'plan',
      preferred_picker = 'snacks',
      keymap_prefix = '<leader>a',
      keymap = {
        editor = {
          ['<leader>am'] = { 'switch_mode' },
          ['<leader>aR'] = { function() require('opencode.ui.ui').render_output(true) end },
          ['<leader>aa'] = { 'toggle', mode = { 'n', 'v' } },
          ['<leader>ai'] = { function() require('opencode.core').open({ new_session = false, focus = 'input' }) end, mode = { 'n', 'v' } }, -- open input without insert mode
          ['<leader>aI'] = { function() require('opencode.core').open({ new_session = true, focus = 'input' }) end, mode = { 'n', 'v' } }, -- open input without insert mode
        },
        output_window = {
          ['<esc>'] = false,
        },
        input_window = {
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
        -- input_height = 0.21,
        loading_animation = {
          frames = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
        },
        input = {
          text = {
            wrap = true, -- Wraps text inside input window
          },
        },
        icons = {
          overrides = {
            header_user = '▏💬',
            border = '▏',
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
      require('tests.manual.renderer_replay').start({ set_statuscolumn = false })
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
  -- {
  --   'OXY2DEV/markview.nvim',
  --   optional = true,
  --   ft = { 'opencode_output' },
  --   opts = {
  --     preview = {
  --       filetypes = { 'opencode_output' },
  --     },
  --   },
  --   opts_extend = { 'preview.filetypes' },
  -- },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    enabled = true,
    cmd = 'RenderMarkdown',
    ft = { 'opencode_output' },

    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      file_types = { 'opencode_output' },
    },
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
