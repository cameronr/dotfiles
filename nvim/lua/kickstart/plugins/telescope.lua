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
        cond = function() return vim.fn.executable 'make' == 1 end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },

      -- Useful for getting pretty icons, but requires a Nerd Font.
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
      { 'debugloop/telescope-undo.nvim' },
      { 'aaronhallaert/advanced-git-search.nvim', cmd = { 'AdvancedGitSearch' } },
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
      local actions = require 'telescope.actions'
      require('telescope').setup {
        -- You can put your default mappings / updates / etc. in here
        --  All the info you're looking for is in `:help telescope.setup()`
        --
        -- defaults = {
        --   mappings = {
        --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
        --   },
        -- },
        defaults = {
          path_display = { truncate = 1 },
          mappings = {
            --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
            i = { ['<esc>'] = actions.close }, -- close on first esc
          },
        },
        pickers = {
          buffers = {
            sort_mru = true,
            ignore_current_buffer = true,
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
      }

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')
      pcall(require('telescope').load_extension, 'undo')
      pcall(require('telescope').load_extension, 'advanced_git_search')

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sl', builtin.help_tags, { desc = '[S]earch he[L]p' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      -- vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      -- vim.keymap.set('n', '<leader>sa', function()
      --   builtin.find_files { find_command = { 'rg', '--files', '--hidden', '-g', '!.git' } }
      -- end, { desc = '[S]earch [Al] Files (no git)' })
      vim.keymap.set(
        'n',
        '<leader>sf',
        function() builtin.find_files { find_command = { 'rg', '--files', '--hidden', '-g', '!.git' } } end,
        { desc = '[S]earch [F]iles' }
      )
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      -- vim.keymap.set('n', '<leader>/', builtin.grep_string, { desc = '[S]earch current Word' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [R]ip grep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

      -- My Additions
      vim.keymap.set('n', '<leader>sc', builtin.command_history, { desc = '[S]earch [C]ommands' })
      vim.keymap.set('n', '<leader>su', '<cmd>Telescope undo<CR>', { desc = '[S]earch [U]ndo' })
      vim.keymap.set('n', '<leader>sp', '<cmd>Telescope notify<CR>', { desc = '[S]earch [P]opup Notifications' })
      vim.keymap.set('n', '<leader>st', '<cmd>TodoTelescope<CR>', { desc = '[S]earch [T]odos' })

      -- Git options
      vim.keymap.set('n', '<leader>shc', '<cmd>Telescope git_commits<CR>', { desc = '[S]earch [G]it [C]ommits' })
      vim.keymap.set('n', '<leader>shb', '<cmd>Telescope git_branches<CR>', { desc = '[S]earch [G]it [B]ranches' })
      vim.keymap.set('n', '<leader>shs', '<cmd>Telescope git_status<CR>', { desc = '[S]earch [G]it [S]tatus' })
      vim.keymap.set('n', '<leader>shh', '<cmd>Telescope git_stash<CR>', { desc = '[S]earch [G]it stas[H]' })
      vim.keymap.set('n', '<leader>shf', '<cmd>Telescope git_bcommits<CR>', { desc = '[S]earch [G]it bu[F]fer commits' })

      vim.keymap.set('n', '<leader>st', '<cmd>TodoTelescope<CR>', { desc = '[S]earch [T]odos' })

      -- Ctrl-r for command history in command mode (like with zsh+fzf)
      vim.keymap.set('c', '<C-r>', builtin.command_history, { desc = '[S]earch [C]ommands' })

      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set(
        'n',
        '<leader>s/',
        function()
          builtin.live_grep {
            grep_open_files = true,
            prompt_title = 'Live Grep in Open Files',
          }
        end,
        { desc = '[S]earch [/] in Open Files' }
      )

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', '<leader>sn', function() builtin.find_files { cwd = vim.fn.stdpath 'config' } end, { desc = '[S]earch [N]eovim files' })
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
