local function save_extra_data(_)
  if not package.loaded['dap'] then return end

  local ok, breakpoints = pcall(require, 'dap.breakpoints')
  if not ok or not breakpoints then return end

  local bps = {}
  local breakpoints_by_buf = breakpoints.get()
  for buf, buf_bps in pairs(breakpoints_by_buf) do
    bps[vim.api.nvim_buf_get_name(buf)] = buf_bps
  end
  if vim.tbl_isempty(bps) then return end
  local extra_data = {
    breakpoints = bps,
  }
  return vim.fn.json_encode(extra_data)
end

local function restore_extra_data(_, extra_data)
  local json = vim.fn.json_decode(extra_data)

  if json.breakpoints then
    local ok, breakpoints = pcall(require, 'dap.breakpoints')

    if not ok or not breakpoints then return end
    for buf_name, buf_bps in pairs(json.breakpoints) do
      for _, bp in pairs(buf_bps) do
        local line = bp.line
        local opts = {
          condition = bp.condition,
          log_message = bp.logMessage,
          hit_condition = bp.hitCondition,
        }
        breakpoints.set(opts, vim.fn.bufnr(buf_name), line)
      end
    end
  end
end

---@module 'lazy'
---@type LazySpec
return {
  'rmagatti/auto-session',
  -- dev = true,
  lazy = false,
  keys = {

    { '<leader>wr', '<cmd>SessionSearch<CR>', desc = 'Session picker' },
    { '<leader>ws', '<cmd>SessionSave<CR>', desc = 'Save session' },
    { '<leader>wD', '<cmd>SessionDelete<CR>', desc = 'Delete session' },
  },

  opts = function(_, opts)
    if Snacks then
      Snacks.toggle({
        name = 'session autosave',
        get = function() return require('auto-session.config').auto_save end,
        set = function() vim.cmd('SessionToggleAutoSave') end,
      }):map('<leader>wa')
    end

    ---@module "auto-session"
    ---@type AutoSession.Config
    local _opts = {
      bypass_save_filetypes = { 'snacks_dashboard' },
      cwd_change_handling = true,
      -- log_level = 'debug',
      lsp_stop_on_restore = true,
      -- git_use_branch_name = true,
      -- git_auto_restore_on_branch_change = true,

      pre_restore_cmds = {
        function() require('harpoon'):sync() end,
      },
      post_restore_cmds = {
        function()
          local harpoon = require('harpoon')
          harpoon.data = require('harpoon.data').Data:new(harpoon.config)
        end,
      },
      save_extra_data = save_extra_data,
      restore_extra_data = restore_extra_data,
      session_lens = {
        load_on_setup = false,
        mappings = {
          delete_session = { 'i', '<A-d>' },
        },
      },
      suppressed_dirs = { '~/', '~/Downloads', '~/Documents', '~/Desktop', '~/tmp' },
    }

    return vim.tbl_deep_extend('force', opts or {}, _opts)
  end,
}
