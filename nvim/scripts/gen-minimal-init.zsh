#!/usr/bin/env zsh

if [[ ! -f lua/options.lua || ! -f lua/keymaps.lua ]]; then
    echo "Error: can't find lua/options.lua or lua/keymaps.lua"
    echo "Make sure you're running the script from the nvim directory"
    exit 1
fi

# Create minimal-init.lua with your fixed lines
cat > minimal-init.lua <<'EOF'
if not vim.g.man_pager then
  vim.g.mapleader = ' '
  vim.g.maplocalleader = ' '
end

vim.g.have_nerd_font = true
EOF

# Append lua/options.lua
cat lua/options.lua >> minimal-init.lua

# Ensure a newline between files
echo >> minimal-init.lua

# Append lua/keymaps.lua
cat lua/keymaps.lua >> minimal-init.lua
