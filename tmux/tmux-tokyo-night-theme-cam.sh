#!/usr/bin/env bash

#Tokyo Night Pallet
declare -A PALLETE=(
    [none]="NONE"
    [bg]="#1a1b26"
    [bg_dark]="#16161e"
    [bg_highlight]="#1a1b26"
    [terminal_black]="#414868"
    [fg]="#c0caf5"
    [fg_dark]="#a9b1d6"
    [fg_gutter]="#3b4261"
    # [dark3]="#545c7e"
    # [dark5]="#737aa2"
    [comment]="#565f89"
    [dark5]="#3b4261"
    [dark3]="#292e42"
    [blue0]="#3d59a1"
    [blue]="#7aa2f7"
    [cyan]="#7dcfff"
    [blue1]="#2ac3de"
    [blue2]="#0db9d7"
    [blue5]="#89ddff"
    [blue6]="#b4f9f8"
    [blue7]="#394b70"
    # [magenta]="#bb9af7"
    # [purple]="#9d7cd8"
    [magenta]="#9f71f4"
    [purple]="#7f42f0"
    [magenta2]="#ff007c"
    [orange]="#ff9e64"
    [yellow]="#e0af68"
    [yellow2]="#f1b355"
    [green]="#9ece6a"
    [green1]="#73daca"
    [green2]="#41a6b5"
    [teal]="#1abc9c"
    [red]="#f7768e"
    [red1]="#db4b4b"
    [white]="#ffffff"
)

function generate_inactive_window_string() {
    local separator_start="#[bg=${PALLETE['dark5']},fg=${PALLETE['bg_highlight']}]${left_separator:?}#[none]"
    local separator_internal="#[bg=${PALLETE['dark3']},fg=${PALLETE['dark5']}]${left_separator:?}#[none]"
    local separator_end="#[bg=${PALLETE[bg_highlight]},fg=${PALLETE['dark3']}]${left_separator:?}#[none]"

    # echo "${separator_start}#[fg=${PALLETE[white]}]#I${separator_internal}#[fg=${PALLETE[white]}] #{?window_zoomed_flag, , }#W ${separator_end}"
    echo "${separator_start}#[fg=${PALLETE[white]}]#I${separator_internal}#[fg=${PALLETE[fg_dark]}] #T ${separator_end}"
}

function generate_active_window_string() {
    separator_start="#[bg=${PALLETE['magenta']},fg=${PALLETE['bg_highlight']}]${left_separator:?}#[none]"
    separator_internal="#[bg=${PALLETE['purple']},fg=${PALLETE['magenta']}]${left_separator:?}#[none]"
    separator_end="#[bg=${PALLETE[bg_highlight]},fg=${PALLETE['purple']}]${left_separator:?}#[none]"

    # echo "${separator_start}#[fg=${PALLETE[white]}]#I${separator_internal}#[fg=${PALLETE[white]}] #{?window_zoomed_flag, , }#W ${separator_end}#[none]"
    echo "${separator_start}#[fg=${PALLETE[white]}]#I${separator_internal}#[fg=${PALLETE[white]}] #T ${separator_end}#[none]"
}


export PALLETE
