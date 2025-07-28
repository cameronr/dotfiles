## My nvim config

Initially based on the fantastic [kickstart-modular](https://github.com/dam9000/kickstart-modular.nvim) project.

I've had a lot of fun tweaking things along the way. Some features:

- Tweaked [folke/tokyonight.nvim](https://github.com/folke/tokyonight.nvim) colors
- Customized [lualine](https://github.com/nvim-lualine/lualine.nvim) with git changes, [LazyVim like filename display](https://github.com/bwpge/lualine-pretty-path), Harpoon support, LSP info, and more
- Automatic sessions via [Auto-session](https://github.com/rmagatti/auto-session)
- [Snacks.nvim](https://github.com/folke/snacks.nvim) with a Telescope feel
- Multiple picker support (snacks, telescope, fzf-lua) controlled by env var (NVIM_PICKER_ENGINE)
- Tweaked [Blink.cmp](https://github.com/Saghen/blink.cmp) config
- Plugin groups controlled by [env vars](https://github.com/cameronr/dotfiles/blob/main/nvim/init.lua#L40-L42)
- nvim-cmp support controlled by env var (NVIM_CMP_ENGINE)
- Light and dark mode theme switching
- [Neogit](https://github.com/NeogitOrg/neogit) + [Diffview](https://github.com/sindrets/diffview.nvim) with Github-like highlighting
- Disabling Treesitter on large js files
- Fully lazy loaded
- Keymaps, so many keymaps
