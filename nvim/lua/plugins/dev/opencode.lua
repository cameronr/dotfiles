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
    cond = function() return vim.fn.executable('opencode') == 1 end,
    cmd = 'Opencode',
    keys = {
      {
        '<leader>ao',
        function()
          load_opencode(function() vim.cmd('Opencode') end)
        end,
        desc = 'Opencode',
      },
    },
    opts = {
      preferred_picker = 'snacks',
      keymap = {
        window = {
          submit = '<c-s>',
          submit_insert = '<c-s>',
          close = false,
          focus_input = false,
          prev_prompt_history = false,
          next_prompt_history = false,
          toggle_pane = false,
        },
      },
      ui = {
        input_width = 0.42,
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
    },
    init = function()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'opencode', -- trigger only for this filetype
        callback = function(args)
          local map = require('opencode.keymap').buf_keymap
          local nav_history = require('opencode.ui.util').navigate_history
          local api = require('opencode.api')

          local prev_prompt_history = '<C-UP>'
          local next_prompt_history = '<C-DOWN>'
          local toggle_pane = '<tab>'
          map(prev_prompt_history, nav_history(prev_prompt_history, 'prev'), args.buf, { 'n' })
          map(next_prompt_history, nav_history(next_prompt_history, 'next'), args.buf, { 'n' })
          map(toggle_pane, api.toggle_pane, args.buf, { 'n' })
        end,
      })

      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'opencode_output', -- trigger only for this filetype
        callback = function(args)
          local map = require('opencode.keymap').buf_keymap
          local api = require('opencode.api')

          local toggle_pane = '<tab>'
          map(toggle_pane, api.toggle_pane, args.buf, { 'n' })
        end,
      })
    end,
    config = function(_, opts)
      local ok, opencode = pcall(require, 'opencode')
      if not ok then return end
      opencode.setup(opts)

      local map = vim.keymap.set
      local api = require('opencode.api')
      map('n', '<leader>aa', api.switch_to_next_mode, { desc = 'Opencode: toggle agent/build' })
      map('n', '<leader>as', api.select_session, { desc = 'Opencode: select session' })
      map('n', '<leader>ap', api.configure_provider, { desc = 'Opencode: configure provider' })
    end,
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    optional = true,
    opts = {
      anti_conceal = { enabled = false },
      file_types = { 'markdown', 'opencode_output' },
    },
    -- ft = { 'markdown', 'Avante', 'copilot-chat', 'opencode_output' },
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
}
