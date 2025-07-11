---@param buf? number
---@return string[]?
local function get_kind_filter(buf)
  local kind_filter = {
    default = { 'Class', 'Constructor', 'Enum', 'Field', 'Function', 'Interface', 'Method', 'Module', 'Namespace', 'Package', 'Property', 'Struct', 'Trait' },
    markdown = false,
    help = false,
    -- you can specify a different filter for each filetype
    lua = {
      'Class',
      'Constructor',
      'Enum',
      'Field',
      'Function',
      'Interface',
      'Method',
      'Module',
      'Namespace',
      -- "Package", -- remove package since luals uses it for control flow structures
      'Property',
      'Struct',
      'Trait',
    },
  }

  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  local ft = vim.bo[buf].filetype
  if kind_filter == false then return end
  if kind_filter[ft] == false then return end
  if type(kind_filter[ft]) == 'table' then return kind_filter[ft] end
  ---@diagnostic disable-next-line: return-type-mismatch
  return type(kind_filter) == 'table' and type(kind_filter.default) == 'table' and kind_filter.default or nil
end

local function symbols_filter(entry, ctx)
  if ctx.symbols_filter == nil then ctx.symbols_filter = get_kind_filter(ctx.bufnr) or false end
  if ctx.symbols_filter == false then return true end
  return vim.tbl_contains(ctx.symbols_filter, entry.kind)
end

---@module 'lazy'
---@type LazySpec
return {
  'ibhagwan/fzf-lua',
  enabled = vim.g.picker_engine == 'fzf',

  -- Borrowed from LazyVim

  cmd = 'FzfLua',

  keys = {
    { '<c-j>', '<c-j>', ft = 'fzf', mode = 't', nowait = true },
    { '<c-k>', '<c-k>', ft = 'fzf', mode = 't', nowait = true },
    {
      '<leader><space>',
      '<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>',
      desc = 'Switch Buffer',
    },
    { '<leader>/', '<cmd>FzfLua live_grep<cr>', desc = 'Grep' },
    { '<leader>:', '<cmd>FzfLua command_history<cr>', desc = 'Command history' },
    { '<leader>sf', '<cmd>FzfLua files<cr>', desc = 'Search Files' },
    { '<leader>sb', '<cmd>FzfLua builtin<cr>', desc = 'FzfLua builtins' },
    { '<leader>s.', '<cmd>FzfLua oldfiles<cr>', desc = 'Recent' },
    -- git
    { '<leader>sgc', '<cmd>FzfLua git_commits<CR>', desc = 'Commits' },
    { '<leader>sgs', '<cmd>FzfLua git_status<CR>', desc = 'Status' },
    -- search
    { '<leader>s"', '<cmd>FzfLua registers<cr>', desc = 'Registers' },
    { '<leader>sa', '<cmd>FzfLua autocmds<cr>', desc = 'Auto commands' },
    { '<leader>s/', '<cmd>FzfLua grep_curbuf<cr>', desc = 'Buffer' },
    { '<leader>sc', '<cmd>FzfLua command_history<cr>', desc = 'Command history' },
    { '<leader>sv', '<cmd>FzfLua commands<cr>', desc = 'Commands' },
    { '<leader>sd', '<cmd>FzfLua diagnostics_document<cr>', desc = 'Document diagnostics' },
    { '<leader>sD', '<cmd>FzfLua diagnostics_workspace<cr>', desc = 'Workspace diagnostics' },
    { '<leader>sh', '<cmd>FzfLua help_tags<cr>', desc = 'Help' },
    { '<leader>sH', '<cmd>FzfLua highlights<cr>', desc = 'Highlights' },
    { '<leader>sj', '<cmd>FzfLua jumps<cr>', desc = 'Jumplist' },
    { '<leader>sk', '<cmd>FzfLua keymaps<cr>', desc = 'Keymaps' },
    { '<leader>sl', '<cmd>FzfLua loclist<cr>', desc = 'Location list' },
    { '<leader>sM', '<cmd>FzfLua man_pages<cr>', desc = 'Man pages' },
    { '<leader>sm', '<cmd>FzfLua marks<cr>', desc = 'Marks' },
    { '<leader>sR', '<cmd>FzfLua resume<cr>', desc = 'Resume' },
    { '<leader>sq', '<cmd>FzfLua quickfix<cr>', desc = 'Quickfix list' },
    { '<leader>sw', '<cmd>FzfLua grep_cword<cr>', desc = 'Currnt word' },
    { '<leader>sw', '<cmd>FzfLua grep_visual<cr>', mode = 'v', desc = 'Selection' },
    { '<leader>sC', '<cmd>FzfLua colorschemes<cr>', desc = 'Colorschemes' },
    { '<leader>sz', '<cmd>FzfLua grep_curbuf<cr>', desc = 'Fuzzy find in buffer' },
    {
      '<leader>ss',
      function()
        require('fzf-lua').lsp_document_symbols({
          regex_filter = symbols_filter,
        })
      end,
      desc = 'Goto Symbol',
    },
    {
      '<leader>sS',
      function()
        require('fzf-lua').lsp_live_workspace_symbols({
          regex_filter = symbols_filter,
        })
      end,
      desc = 'Goto Symbol (Workspace)',
    },
  },

  opts = function(_, _)
    local config = require('fzf-lua.config')
    local actions = require('fzf-lua.actions')

    -- Quickfix
    config.defaults.keymap.fzf['ctrl-q'] = 'select-all+accept'
    config.defaults.keymap.fzf['ctrl-u'] = 'half-page-up'
    config.defaults.keymap.fzf['ctrl-d'] = 'half-page-down'
    config.defaults.keymap.fzf['ctrl-x'] = 'jump'
    config.defaults.keymap.fzf['ctrl-f'] = 'preview-page-down'
    config.defaults.keymap.fzf['ctrl-b'] = 'preview-page-up'
    config.defaults.keymap.builtin['<c-f>'] = 'preview-page-down'
    config.defaults.keymap.builtin['<c-b>'] = 'preview-page-up'
    config.defaults.keymap.builtin['<c-p>'] = 'toggle-preview'
    config.defaults.keymap.builtin['<c-w>'] = 'toggle-preview-cw'

    -- Trouble
    config.defaults.actions.files['ctrl-t'] = require('trouble.sources.fzf').actions.open

    local img_previewer ---@type string[]?
    for _, v in ipairs({
      { cmd = 'ueberzug', args = {} },
      { cmd = 'chafa', args = { '{file}', '--format=symbols' } },
      { cmd = 'viu', args = { '-b' } },
    }) do
      if vim.fn.executable(v.cmd) == 1 then
        img_previewer = vim.list_extend({ v.cmd }, v.args)
        break
      end
    end

    return {
      'default-title',
      fzf_colors = true,
      fzf_opts = {
        ['--no-scrollbar'] = true,
        ['--layout'] = 'default',
        ['--cycle'] = '',
      },
      defaults = {
        formatter = 'path.filename_first',
        -- formatter = 'path.dirname_first',
      },
      previewers = {
        builtin = {
          extensions = {
            ['png'] = img_previewer,
            ['jpg'] = img_previewer,
            ['jpeg'] = img_previewer,
            ['gif'] = img_previewer,
            ['webp'] = img_previewer,
          },
          ueberzug_scaler = 'fit_contain',
        },
      },
      winopts = {
        width = 0.85,
        height = 0.85,
        row = 0.5,
        col = 0.5,
        preview = {
          scrollchars = { '┃', '' },
          vertical = 'down:50%',
          horizontal = 'right:50%',
        },
      },
      buffers = {
        fzf_opts = {
          -- ['--header-lines'] = 0,
        },
        actions = {
          ['alt-d'] = { fn = actions.buf_del, reload = true },
          ['ctrl-x'] = false,
        },
      },

      files = {
        cwd_prompt = false,
        actions = {
          ['alt-i'] = { actions.toggle_ignore },
          ['alt-h'] = { actions.toggle_hidden },
        },
      },
      grep = {
        RIPGREP_CONFIG_PATH = vim.env.RIPGREP_CONFIG_PATH,
        actions = {
          ['alt-i'] = { actions.toggle_ignore },
          ['alt-h'] = { actions.toggle_hidden },
        },
      },
      lsp = {
        symbols = {
          symbol_hl = function(s) return 'TroubleIcon' .. s end,
          symbol_fmt = function(s) return s:lower() .. '\t' end,
          child_prefix = false,
        },
        code_actions = {
          previewer = vim.fn.executable('delta') == 1 and 'codeaction_native' or nil,
        },
      },
    }
  end,

  config = function(_, opts)
    if opts[1] == 'default-title' then
      -- use the same prompt for all pickers for profile `default-title` and
      -- profiles that use `default-title` as base profile
      local function fix(t)
        t.prompt = t.prompt ~= nil and ' ' or nil
        for _, v in pairs(t) do
          if type(v) == 'table' then fix(v) end
        end
        return t
      end
      opts = vim.tbl_deep_extend('force', fix(require('fzf-lua.profiles.default-title')), opts)
      opts[1] = nil
    end
    require('fzf-lua').setup(opts)
  end,

  init = function()
    -- Custom LazyVim option to configure vim.ui.select
    local ui_select = function(fzf_opts, items)
      return vim.tbl_deep_extend('force', fzf_opts, {
        prompt = ' ',
        winopts = {
          title = ' ' .. vim.trim((fzf_opts.prompt or 'Select'):gsub('%s*:%s*$', '')) .. ' ',
          title_pos = 'center',
        },
      }, fzf_opts.kind == 'codeaction' and {
        winopts = {
          layout = 'vertical',
          -- height is number of items minus 15 lines for the preview, with a max of 80% screen height
          height = math.floor(math.min(vim.o.lines * 0.8 - 16, #items + 2) + 0.5) + 16,
          width = 0.75,
          -- preview = not vim.tbl_isempty(LazyVim.lsp.get_clients({ bufnr = 0, name = 'vtsls' })) and {
          --   layout = 'vertical',
          --   vertical = 'down:15,border-top',
          --   hidden = 'hidden',
          -- } or {
          --   layout = 'vertical',
          --   vertical = 'down:15,border-top',
          -- },

          preview = {
            layout = 'vertical',
            vertical = 'up:15,border-bottom',
          },
        },
      } or {
        winopts = {
          width = 0.5,
          -- height is number of items, with a max of 80% screen height
          height = math.floor(math.min(vim.o.lines * 0.8, #items + 2) + 0.5),
        },
      })
    end

    ---@diagnostic disable-next-line: duplicate-set-field
    vim.ui.select = function(...)
      require('fzf-lua').register_ui_select(ui_select)
      return vim.ui.select(...)
    end

    --
    -- LazyVim.on_very_lazy(function()
    --   vim.ui.select = function(...)
    --     require('lazy').load({ plugins = { 'fzf-lua' } })
    --     local opts = LazyVim.opts('fzf-lua') or {}
    --     require('fzf-lua').register_ui_select(opts.ui_select or nil)
    --     return vim.ui.select(...)
    --   end
    -- end)
  end,
}
