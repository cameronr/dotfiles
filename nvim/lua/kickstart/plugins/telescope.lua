-- NOTE: Plugins can specify dependencies.
--
-- The dependencies are proper plugin specifications as well - anything
-- you do for a plugin at the top level, you can do for a dependency.
--
-- Use the `dependencies` key to specify the dependencies of a particular plugin

return {
  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
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

      -- Useful for getting pretty icons, but requires a Nerd Font.
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
      { 'aaronhallaert/advanced-git-search.nvim', cmd = { 'AdvancedGitSearch' } },
      { 'AckslD/nvim-neoclip.lua' },
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

      require('telescope').setup({
        -- You can put your default mappings / updates / etc. in here
        --  All the info you're looking for is in `:help telescope.setup()`
        --

        defaults = {
          path_display = { truncate = 1 },
          mappings = {
            i = {
              ['<C-ENTER>'] = 'to_fuzzy_refine',
              ['<ESC>'] = actions.close, -- close on first esc
              -- ['<c-q>'] = actions.smart_send_to_qflist + my_actions.open_trouble,
              ['<C-Q>'] = actions.smart_send_to_qflist + my_actions.open_trouble_qflist,
              ['<C-L>'] = actions.smart_send_to_loclist + my_actions.open_trouble_loclist,
              ['<C-SPACE>'] = actions.complete_tag,
              ['<C-Down>'] = actions.cycle_history_next,
              ['<C-Up>'] = actions.cycle_history_prev,
              ['<C-T>'] = require('trouble.sources.telescope').open,
              ['<M-T>'] = require('trouble.sources.telescope').add,
            },
          },
        },
        pickers = {
          buffers = {
            sort_mru = true,
            -- ignore_current_buffer = true,
            mappings = {
              i = {
                ['<c-d>'] = actions.delete_buffer + actions.move_to_top, -- delete buffer
              },
            },
          },
          builtin = {
            include_extensions = false,
          },
          colorscheme = {
            enable_preview = true,
          },
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
          advanced_git_search = {
            browse_command = 'GBrowse {commit_hash}',
            diff_plugin = 'diffview',
            entry_default_author_or_date = 'author',

            -- See Config
          },
        },
      })

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')
      pcall(require('telescope').load_extension, 'advanced_git_search')
      pcall(require('telescope').load_extension, 'neoclip')

      -- See `:help telescope.builtin`
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>sl', builtin.help_tags, { desc = 'Help' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = 'Keymaps' })
      -- vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      -- vim.keymap.set('n', '<leader>sa', function()
      --   builtin.find_files { find_command = { 'rg', '--files', '--hidden', '-g', '!.git' } }
      -- end, { desc = '[S]earch [Al] Files (no git)' })
      vim.keymap.set(
        'n',
        '<leader>sf',
        function() builtin.find_files({ find_command = { 'rg', '--files', '--hidden', '-g', '!.git' } }) end,
        { desc = 'Files' }
      )
      vim.keymap.set('n', '<leader>sb', builtin.builtin, { desc = 'Telescope builtins' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = 'Current word' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = 'Grep' })
      vim.keymap.set('n', '<leader>/', builtin.live_grep, { desc = 'Grep' })
      vim.keymap.set('n', '<leader>sd', '<cmd>Telescope diagnostics bufnr=0<cr>', { desc = 'Diagnostics' })
      vim.keymap.set('n', '<leader>sD', builtin.diagnostics, { desc = 'Diagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = 'Resume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = 'Recent Files' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = 'Buffers' })

      -- My Additions
      vim.keymap.set('n', '<leader>sa', '<cmd>Telescope autocommands<cr>', { desc = 'Auto Commands' })
      vim.keymap.set('n', '<leader>:', '<cmd>Telescope command_history<cr>', { desc = 'Command History' })
      vim.keymap.set('n', '<leader>sc', builtin.command_history, { desc = 'Commands' })
      vim.keymap.set('n', '<leader>sC', '<cmd>Telescope commands<cr>', { desc = 'Commands' })
      vim.keymap.set('n', '<leader>sp', '<cmd>Telescope notify<CR>', { desc = 'Popup notifications' })
      vim.keymap.set('n', '<leader>sn', '<cmd>Telescope notify<CR>', { desc = 'Notifications' })
      vim.keymap.set('n', '<leader>sj', '<cmd>Telescope jumplist<cr>', { desc = 'Jumplist' })
      vim.keymap.set('n', '<leader>sl', '<cmd>Telescope loclist<cr>', { desc = 'Location List' })
      vim.keymap.set('n', '<leader>sm', '<cmd>Telescope marks<cr>', { desc = 'Marks' })
      vim.keymap.set('n', '<leader>so', '<cmd>Telescope vim_options<cr>', { desc = 'Options' })

      -- Git options
      vim.keymap.set('n', '<leader>shc', '<cmd>Telescope git_commits<CR>', { desc = 'git commits' })
      vim.keymap.set('n', '<leader>shb', '<cmd>Telescope git_branches<CR>', { desc = 'git branches' })
      vim.keymap.set('n', '<leader>shs', '<cmd>Telescope git_status<CR>', { desc = 'git status' })
      vim.keymap.set('n', '<leader>shh', '<cmd>Telescope git_stash<CR>', { desc = 'git stash' })
      vim.keymap.set('n', '<leader>shf', '<cmd>Telescope git_bcommits<CR>', { desc = 'git buffer commits' })

      -- Ctrl-r for command history in command mode (like with zsh+fzf)
      vim.keymap.set('n', '<leader>s"', '<cmd>Telescope neoclip<CR>', { desc = 'Yanks' })

      -- Slightly advanced example of overriding default behavior and theme
      -- vim.keymap.set('n', '<leader>/', function()
      --   -- You can pass additional configuration to Telescope to change the theme, layout, etc.
      --   builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown({
      --     winblend = 10,
      --     previewer = false,
      --   }))
      -- end, { desc = 'Fuzzily search in current buffer' })

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set(
        'n',
        '<leader>s/',
        function()
          builtin.live_grep({
            grep_open_files = true,
            prompt_title = 'Live Grep in Open Files',
          })
        end,
        { desc = 'Open Files' }
      )

      -- Ctrl-r for command history in command mode (like with zsh+fzf)
      vim.keymap.set('c', '<C-r>', builtin.command_history, { desc = 'commands' })
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
