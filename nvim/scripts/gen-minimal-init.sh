#!/bin/bash

if [[ ! -f lua/globals.lua ]]; then
    echo "Error: can't find lua/globals.lua"
    echo "Make sure you're running the script from the nvim directory"
    exit 1
fi

files=(
    "lua/globals.lua"
    "lua/options.lua"
    "lua/keymaps.lua"
    "lua/autocmds.lua"
    "lua/minimal-custom.lua"
)

for file in "${files[@]}"; do
    if [[ -f "$file" ]]; then
        cat "$file"
        echo # Add blank line after each file
    fi
done >minimal-init.lua
