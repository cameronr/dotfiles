DOTFILES="${HOME}/dotfiles"

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

ZIM_HOME="${XDG_CACHE_HOME:-$HOME/.cache}/zim"

# Download zimfw plugin manager if missing.
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
    curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
fi

# Install missing modules and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
    source ${ZIM_HOME}/zimfw.zsh init
fi

## Settings that must be set before zim init.zsh
# Clear FZF_DEFAULT_OPTS so we don't get duplicates when running under tmux
unset FZF_DEFAULT_OPTS

# Globbing should be case sensitive, in quotes to make beautysh happy
zstyle ':zim:glob' "case-sensitivity" sensitive

# Initialize modules.
source ${ZIM_HOME}/init.zsh

## Settings after zim modules loaded

# Change some settings set by zimfw
# I like the default grep highlights vs what zimfw/utility sets
unset GREP_COLOR GREP_COLORS

# Completion styling
# For command completion, don't use prompt colors
# zstyle ':completion:*:descriptions' format '-- %d --'
# Actually, disable entirely since I don't like the dot next to the
# command name
zstyle -d ':completion:*:descriptions' format
zstyle -d ':completion:*:warnings' format

# Disable zsh-syntax-highlighting's highlighting on paste
zle_highlight+=(paste:none)

# Set up history
HISTFILE=~/.zsh_history
SAVEHIST=100000
HISTSIZE=100000
HISTDUP=erase
setopt    SHARE_HISTORY        # Share history across terminals
setopt    INC_APPEND_HISTORY   # Append history to the history file (no overwriting) when command starts
setopt    HIST_IGNORE_SPACE    # don't log history with a leading space
setopt    HIST_IGNORE_ALL_DUPS # Delete old recorded entry if new entry is a duplicate.
setopt    HIST_SAVE_NO_DUPS    # Don't write duplicate entries in the history file.
setopt    HIST_IGNORE_DUPS     # Don't record an entry that was just recorded again.
setopt    HIST_FIND_NO_DUPS    # Don't surface duplicate entries in the history file.


# Set vim key bindings
bindkey -v

# But keep some emacs-ness
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^D' delete-char
# map alt-x to kill line (because tmux uses c-k)
bindkey '^[x' kill-line

# Clear screen with C-g (because C-l is for switching panes in nvim/tmux)
bindkey '^G' clear-screen

# # wrap arrows in cmd mode, forward-char doesn't work because of zsh limitation
bindkey -M vicmd '^[[C' forward-char
bindkey -M vicmd '^[OC' forward-char
bindkey -M vicmd '^[[D' backward-char
bindkey -M vicmd '^[OD' backward-char

# better history search
bindkey "^[[A" history-substring-search-up
bindkey "^[OA" history-substring-search-up
bindkey "^[[B" history-substring-search-down
bindkey "^[OB" history-substring-search-down
# 208 is orange
export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='fg=208,bold'
export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='fg=red,bold'

# case sensitive history search
export HISTORY_SUBSTRING_SEARCH_GLOBBING_FLAGS=""

# Always starting with insert mode for each command line
ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT

# Enable ZVM system clipboard support
ZVM_SYSTEM_CLIPBOARD_ENABLED=true

# Set tmux tab titles with customized icon
source $DOTFILES/zsh/title-override.zsh

# safe aliases
alias cp='cp -i'
alias mv='mv -i'

# set vim as editor
export EDITOR=vim
alias vi='vim'

if [[ (( $commands[nvim] )) ]]; then
    export EDITOR=nvim
    export MANPAGER="nvim --cmd 'set laststatus=0 | let g:man_pager=1' +'set statuscolumn= nowrap laststatus=0' +Man\!"
    alias vim='nvim'
    alias v='nvim'
    alias n='nvim'

    NVIM_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}/nvim"
    if [[ ! -d "$NVIM_HOME" ]]; then
        ln -sn $DOTFILES/nvim "$NVIM_HOME"
    fi
fi

# set up zoxide and use it as cd (if installed)
if [[ (( $commands[zoxide] )) ]]; then
    eval "$(zoxide init --cmd cd zsh)"
fi

# set up eza, if installed
if [[ (( $commands[eza] )) ]]; then
    LS_CMD='eza -F --color=always --icons=always --no-quotes --color-scale=age'
    alias ls=$LS_CMD
    FZF_DIR_PREVIEW="$LS_CMD -1 {} | head -500"

    # Needed on mac where Eza's default config is in Application Support
    export EZA_CONFIG_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/eza"

    # Unset LS_COLORS to use the eza theme
    unset LS_COLORS

    # with --color-scale=age, dates can look a little too dim (default is 40)
    export EZA_MIN_LUMINANCE=60

else
    alias ls='ls -F --color=always'
    zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
fi

# set up bat, if installed
if [[ (( $commands[bat] )) ]]; then
    export BAT_THEME=tokyonight_night
    alias cat='bat'
    FZF_FILE_PREVIEW="bat -n --color=always --line-range :500 {}"
fi

# set up fd, if installed
if [[ (( $commands[fd] )) ]]; then
    export FZF_CTRL_T_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"

    # It's a bummer that type=d doesn't pick up symlinks to directories
    export FZF_ALT_C_COMMAND="fd --type=d --type=symlink --hidden --strip-cwd-prefix --exclude .git"
fi

# set up thefuck, if installed
if [[ (( $commands[thefuck] )) ]]; then
    eval $(thefuck --alias fk)
fi

# set up rg, if installed
if [[ (( $commands[rg] )) ]]; then
    export RIPGREP_CONFIG_PATH=$DOTFILES/.ripgreprc
fi

# set up fzf if installed
if [[ (( $commands[fzf] )) ]]; then

    # Load main fzf integration (but after zsh-vi-mode)
    if [[ $ZVM_NAME == 'zsh-vi-mode' ]]; then
        # zvm_after_init_commands+=('source <(fzf --zsh)')
        source <(fzf --zsh)

        # zsh-vi-mode replaces the ^R keymap but doing zvm_after_init_commands+=('source <(fzf --zsh)')
        # loads fzf too late and causes it to occasionally overwrite the prompt when selecting an option
        zvm_after_init_commands+=("bindkey '^R' fzf-history-widget")
    else
        source <(fzf --zsh)
    fi

    # Use fzf for normal mode search
    bindkey -M vicmd '/' fzf-history-widget

    # Just as a note, default keybind for scrolling the preview window is shift up/down

    # Defaults for when eza/bat/fd not installed
    : ${FZF_FILE_PREVIEW="head -500 {}"}
    : ${FZF_DIR_PREVIEW="ls --color=always {} | head -500"}

    # Set up a preview that can handle files and directories
    show_file_or_dir_preview="if [ -d {} ]; then $FZF_DIR_PREVIEW; else $FZF_FILE_PREVIEW; fi"
    export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"

    # clear FZF_DEFAULT_OPTS so we don't get duplicates when running under tmux
    # unset FZF_DEFAULT_OPTS

    # Tokyonight-night fzf theme
    # source $ZIM_HOME/modules/tokyonight.nvim/extras/fzf/tokyonight_night.sh

    # I like orange as the highlight color, blue border
    export FZF_DEFAULT_OPTS=$(echo "$FZF_DEFAULT_OPTS" | sed 's/--color=hl+:#2ac3de/--color=hl+:#ff9e64/g; s/--color=hl:#2ac3de/--color=hl:#ff9e64/g; s/--color=border:#27a1b9/--color=border:#7aa2f7/')

    # Turn on wrap around and make ctrl-space select and go down
    export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --cycle --bind=ctrl-space:toggle+down"

    # set completion opts to same colors
    export FZF_COMPLETION_OPTS="$FZF_DEFAULT_OPTS"

    # set theme colors in fzf-tab as it doesn't pick up FZF_DEFAULT_OPTS automatically
    zstyle ':fzf-tab:*' fzf-flags $(echo $FZF_DEFAULT_OPTS | tr ' ' '\n')

    # disable sort when completing `git checkout`
    zstyle ':completion:*:git-checkout:*' sort false

    # Disabling groups as I don't really understand them and a unified search feels more natural
    # set descriptions format to enable group support
    # NOTE: don't use escape sequences here, fzf-tab will ignore them
    # zstyle ':completion:*:descriptions' format '[%d]'
    # zstyle ':fzf-tab:*' switch-group '<' '>'

    # force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
    zstyle ':completion:*' menu no

    # zstyle needs an unexpanded $realpath in place of {}
    zstyle ':fzf-tab:complete:cd:*' fzf-preview ${FZF_DIR_PREVIEW//\{\}/\$realpath}
    zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview ${FZF_DIR_PREVIEW//\{\}/\$realpath}
fi


## Set up p10k
# To customize prompt, run `p10k configure` or edit ~/dotfiles/.p10k.zsh.
[[ ! -f $DOTFILES/.p10k.zsh ]] || source $DOTFILES/.p10k.zsh

typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=magenta
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

