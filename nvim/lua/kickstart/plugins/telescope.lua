-- NOTE: Plugins can specify dependencies.
--
-- The dependencies are proper plugin specifications as well - anything
-- you do for a plugin at the top level, you can do for a dependency.
--
-- Use the `dependencies` key to specify the dependencies of a particular plugin

return {
  ---@module 'lazy'
  ---@type LazySpec
  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    enabled = vim.g.picker_engine == 'telescope',
    -- branch = '0.1.x',
    -- dev = true,
    dependencies = {
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',

        -- `build` is used to run some command when the plugin is installed/updated.
        -- This is only run then, not every time Neovim starts up.
        build = 'make',

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function() return vim.fn.executable('make') == 1 end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
    },

    cmd = 'Telescope',

    keys = {
      { '<leader>sh', '<cmd>Telescope help_tags<cr>', desc = 'Help' },
      { '<leader>sk', '<cmd>Telescope keymaps<cr>', desc = 'Keymaps' },
      { '<leader>sf', '<cmd>Telescope find_files<cr>', desc = 'Search Files' },
      { '<leader>sb', '<cmd>Telescope builtin<cr>', desc = 'Telescope builtins' },
      { '<leader>sw', '<cmd>Telescope grep_string<cr>', desc = 'Current word' },
      { '<leader>/', '<cmd>Telescope live_grep<cr>', desc = 'Grep' },
      { '<leader>sd', '<cmd>Telescope diagnostics bufnr=0<cr>', desc = 'Buffer Diagnostics' },
      { '<leader>sD', '<cmd>Telescope diagnostics<cr>', desc = 'Diagnostics' },
      { '<leader>sr', '<cmd>Telescope resume<cr>', desc = 'Resume' },
      { '<leader>s.', '<cmd>Telescope oldfiles<cr>', desc = 'Recent Files' },
      { '<leader>so', '<cmd>Telescope oldfiles<cr>', desc = 'Recent Files' },
      { '<leader><leader>', '<cmd>Telescope buffers<cr>', desc = 'Buffers' },

      -- My Additions
      { '<leader>sa', '<cmd>Telescope autocommands<cr>', desc = 'Auto Commands' },
      { '<leader>:', '<cmd>Telescope command_history<cr>', desc = 'Command History' },
      { '<leader>sc', '<cmd>Telescope command_history<cr>', desc = 'Commands' },
      { '<leader>sC', '<cmd>Telescope colorscheme<cr>', desc = 'Colorschemes' },
      { '<leader>sv', '<cmd>Telescope commands<cr>', desc = 'Vim Commands' },
      { '<leader>sn', '<cmd>Telescope notify<cr>', desc = 'Notifications' },
      { '<leader>sj', '<cmd>Telescope jumplist<cr>', desc = 'Jumplist' },
      { '<leader>sH', '<cmd>Telescope highlights<cr>', desc = 'Highlights' },
      { '<leader>sl', '<cmd>Telescope loclist<cr>', desc = 'Location List' },
      { '<leader>sm', '<cmd>Telescope marks<cr>', desc = 'Marks' },
      { '<leader>so', '<cmd>Telescope vim_options<cr>', desc = 'Options' },

      -- Git options
      { '<leader>sgc', '<cmd>Telescope git_commits<cr>', desc = 'git commits' },
      { '<leader>sgb', '<cmd>Telescope git_branches<cr>', desc = 'git branches' },
      { '<leader>sgs', '<cmd>Telescope git_status<cr>', desc = 'git status' },
      { '<leader>sgz', '<cmd>Telescope git_stash<cr>', desc = 'git stash' },
      { '<leader>sgf', '<cmd>Telescope git_bcommits<cr>', desc = 'git buffer commits' },

      { '<leader>sy', '<cmd>Telescope neoclip<cr>', desc = 'Yanks' },
      { '<leader>s"', '<cmd>Telescope registers<cr>', desc = 'Registers' },

      -- Slightly advanced example of overriding default behavior and theme
      { '<leader>sz', '<cmd>Telescope current_buffer_fuzzy_find<cr>', desc = 'Fuzzy search' },

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      {
        '<leader>s/',
        function()
          require('telescope.builtin').live_grep({
            grep_open_files = true,
            prompt_title = 'Live Grep in Open Files',
          })
        end,
        desc = 'Open Files',
      },

      -- Ctrl-r for command history in command mode (like with zsh+fzf)
      { mode = 'c', '<C-r>', '<cmd>Telescope command_history<cr>', desc = 'commands' },
    },

    config = function()
      -- Telescope is a fuzzy finder that comes with a lot of different things that
      -- it can fuzzy find! It's more than just a "file finder", it can search
      -- many different aspects of Neovim, your workspace, LSP, and more!
      --
      -- The easiest way to use Telescope, is to start by doing something like:
      --  :Telescope help_tags
      --
      -- After running this command, a window will open up and you're able to
      -- type in the prompt window. You'll see a list of `help_tags` options and
      -- a corresponding preview of the help.
      --
      -- Two important keymaps to use while in Telescope are:
      --  - Insert mode: <c-/>
      --  - Normal mode: ?
      --
      -- This opens a window that shows you all of the keymaps for the current
      -- Telescope picker. This is really useful to discover what Telescope can
      -- do as well as how to actually do it!

      -- [[ Configure Telescope ]]
      -- See `:help telescope` and `:help telescope.setup()`
      local actions = require('telescope.actions')

      -- Make qflist/loclist open trouble
      local transform_mod = require('telescope.actions.mt').transform_mod
      local my_actions = {
        open_trouble_qflist = function(_) vim.cmd([[Trouble qflist open]]) end,
        open_trouble_loclist = function(_) vim.cmd([[Trouble loclist open]]) end,
      }
      my_actions = transform_mod(my_actions)

      local multiopen = function(prompt_bufnr)
        local picker = require('telescope.actions.state').get_current_picker(prompt_bufnr)
        local multi = picker:get_multi_selection()

        if vim.tbl_isempty(multi) then
          require('telescope.actions').select_default(prompt_bufnr)
          return
        end

        require('telescope.actions').close(prompt_bufnr)
        for _, entry in pairs(multi) do
          local filename = entry.filename or entry.value
          local lnum = entry.lnum or 1
          local lcol = entry.col or 1
          if filename then
            vim.cmd(string.format('edit +%d %s', lnum, filename))
            vim.cmd(string.format('normal! %dG%d|', lnum, lcol))
          end
        end
      end

      -- If we have ripgrep, add some flags
      local find_files_command
      if vim.fn.executable('rg') == 1 then
        --
        find_files_command = { 'rg', '--files', '-L', '--hidden', '-g', '!.git', '-g', '!node_modules/', '-g', '!venv' }
      end

      require('telescope').setup({
        -- You can put your default mappings / updates / etc. in here
        --  All the info you're looking for is in `:help telescope.setup()`
        --

        defaults = {
          path_display = {
            filename_first = {
              reverse_directories = false,
            },
          },
          layout_config = {
            horizontal = { preview_width = 0.45 },
          },
          mappings = {
            i = {
              ['<ESC>'] = actions.close, -- close on first esc
              ['<C-Q>'] = actions.smart_send_to_qflist + my_actions.open_trouble_qflist,
              ['<C-L>'] = actions.smart_send_to_loclist + my_actions.open_trouble_loclist,
              ['<M-Space>'] = actions.complete_tag,
              ['<C-Down>'] = actions.cycle_history_next,
              ['<C-Up>'] = actions.cycle_history_prev,
              ['<C-T>'] = require('trouble.sources.telescope').open,
              ['<M-T>'] = require('trouble.sources.telescope').add,
              ['<C-P>'] = require('telescope.actions.layout').toggle_preview,
              ['<C-W>'] = require('telescope.actions.layout').cycle_layout_prev,
              ['<C-h>'] = 'which_key',
              ['<cr>'] = multiopen,
              ['<C-Space>'] = actions.to_fuzzy_refine,
            },
          },
        },
        pickers = {
          buffers = {
            sort_mru = true,
            -- ignore_current_buffer = true,
            mappings = {
              i = {
                -- ['<M-d>'] = actions.delete_buffer,
              },
            },
          },
          find_files = {
            find_command = find_files_command,
          },
          live_grep = {
            additional_args = function()
              return {
                '--hidden',
                '--glob',
                '!**/.git/*',
                '--glob',
                '!**/node[-_]modules/*',
                '--glob',
                '!**/.venv/*',
              }
            end,
          },
          builtin = {
            include_extensions = false,
          },
          colorscheme = {
            enable_preview = true,
          },
          current_buffer_fuzzy_find = {
            -- no preview
            layout_config = {
              horizontal = { preview_width = 0 },
            },
          },
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      })

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')
      pcall(require('telescope').load_extension, 'neoclip')
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
