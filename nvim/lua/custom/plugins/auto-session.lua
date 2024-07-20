return {
  'rmagatti/auto-session',
  -- dev = true,
  lazy = false,
  keys = {

    { '<leader>wr', '<cmd>SessionSearch<CR>', desc = 'Session picker' },
    { '<leader>ws', '<cmd>SessionSave<CR>', desc = 'Save session' },
    { '<leader>wa', '<cmd>SessionToggleAutoSave<CR>', desc = 'Toggle autosave session' },
  },

  -- 'cameronr/auto-session',
  -- branch = 'args-testing',
  config = function()
    require('auto-session').setup({
      -- don't save when it's just the dashboard, or a nvim-notify buffer
      bypass_session_save_file_types = { 'alpha', 'notify' },
      -- auto_restore_enabled = true,
      -- auto_save_enabled = true,
      -- auto_save_enabled = function(launched_with_args)
      --   vim.notify('auto_save_enabled callback: ' .. vim.inspect(launched_with_args))
      --   return true
      -- end,

      -- auto_session_use_git_branch = true,

      -- log_level = 'debug',

      auto_session_suppress_dirs = { '~/', '~/Downloads', '~/Documents', '~/Desktop', '~/tmp' },
      -- auto_session_root_dir = '/tmp/sessions',
      -- auto_session_enable_last_session = true,

      session_lens = {
        previewer = true,
        -- session_control = {
        --   control_dir = '/tmp/as-control-dir/',
        -- },
      },
      cwd_change_handling = {
        restore_upcoming_session = true,
      },
      --
      -- save_extra_cmds = {
      --   function() return [[echo "hello world"]] end,
      -- },

      -- args_allow_single_directory = true,
      -- args_allow_files = true,
      -- args_allow_files_auto_save = function()
      --   local supported_buffers = 0
      --
      --   local buffers = vim.api.nvim_list_bufs()
      --   for _, buf in ipairs(buffers) do
      --     -- Check if the buffer is valid and loaded
      --     if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
      --       local path = vim.api.nvim_buf_get_name(buf)
      --       if vim.fn.filereadable(path) ~= 0 then supported_buffers = supported_buffers + 1 end
      --     end
      --   end
      --
      --   -- If we have more 2 or more supported buffers, save the session
      --   vim.notify('supported: ' .. supported_buffers)
      --   return supported_buffers >= 2
      -- end,

      -- args_allow_files_auto_save = function()
      --   local supported = 0
      --
      --   local tabpages = vim.api.nvim_list_tabpages()
      --   for _, tabpage in ipairs(tabpages) do
      --     local windows = vim.api.nvim_tabpage_list_wins(tabpage)
      --     for _, window in ipairs(windows) do
      --       local buffer = vim.api.nvim_win_get_buf(window)
      --       local file_name = vim.api.nvim_buf_get_name(buffer)
      --       if vim.fn.filereadable(file_name) ~= 0 then supported = supported + 1 end
      --     end
      --   end
      --
      --   -- If we have 2 or more windows with supported buffers, save the session
      --   vim.notify('supported: ' .. supported)
      --   return supported >= 2
      -- end,

      pre_save_cmds = {
        function()
          -- Close any tabs with these filetypes
          local fts_to_match = { 'Diffview' }

          -- Auto-session close unsupported will only close the DiffView window, I want to close
          -- the whole tab
          -- Look for any windows with buffers that match fts_to_match
          local function should_close_tab(tabpage)
            local windows = vim.api.nvim_tabpage_list_wins(tabpage)
            for _, window in ipairs(windows) do
              local buffer = vim.api.nvim_win_get_buf(window)
              local filetype = vim.api.nvim_get_option_value('filetype', { buf = buffer })
              for _, v in ipairs(fts_to_match) do
                if string.find(filetype, '^' .. v) then return true end
              end
            end
            return false
          end

          -- Close any tabs that have the filetypes in fts_to_match
          local tabpages = vim.api.nvim_list_tabpages()
          for _, tabpage in ipairs(tabpages) do
            if should_close_tab(tabpage) then
              local tabNr = vim.api.nvim_tabpage_get_number(tabpage)
              vim.cmd('tabclose ' .. tabNr)
            end
          end
        end,
      },

      -- no_restore_cmds = {
      --   function() vim.notify('no restore alive: ' .. debug.traceback()) end,
      -- },
    })
  end,
}
