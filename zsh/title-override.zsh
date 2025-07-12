
# Override OMZ's title function for two reasons:
# 1. If we're in an ssh session, add the machine name
# 2. Add an icon for the currently running command (if we have one)
source $DOTFILES/zsh/get-icon-for-command.zsh
functions -c title omz_title
title () {
    local CMD=$1

    # ALways add the machine name if we're in an ssh session
    if [[ -n "$SSH_TTY" ]]; then
        if [[ $1 != *"%m"* ]]; then
            # %n is the user, but i don't think we need it
            # CMD="%n@%m:$1"
            CMD="%m:$1"
        fi
        if [[ $2 != *"%m"* ]]; then
            LINE="%m:$2"
        fi
    fi
    # echo "title cmd:'$CMD' line:'$LINE'"
    local ICON=$(get_icon_for_command "$1")
    local CMD_WITH_ICON="${ICON}$CMD"

    # Zsh doesn't set tab/window with a tmux terminal, so we do it oursevles
    if [[ "$TERM" == "tmux-256color" ]]; then
        # Don't set the title if inside emacs, unless using vterm
        [[ -n "${INSIDE_EMACS:-}" && "$INSIDE_EMACS" != vterm ]] && return

        print -Pn "\e]2;${CMD_WITH_ICON:q}\a" # set window name
        print -Pn "\e]1;${CMD_WITH_ICON:q}\a" # set tab name
    else
        omz_title $CMD_WITH_ICON
    fi
}

# We also don't need the cwd hook as p10k handles all of that for us (and having this hook
# introduces a visual glitch)
add-zsh-hook -d precmd omz_termsupport_cwd
