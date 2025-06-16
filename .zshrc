DOTFILES="${HOME}/dotfiles"

# if [[ $(( ${+commands[starship]} )) ]]; then
#     USE_STARSHIP=true
# fi

if ! [[ -n $USE_STARSHIP ]]; then
    # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
    # Initialization code that may require console input (password prompts, [y/n]
    # confirmations, etc.) must go above this block; everything else may go below.
    if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
        source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
    fi
fi

# Zinit initialization
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

if ! [[ -n $USE_STARSHIP ]]; then
    # Load Powerlevel10k
    zinit ice depth=1; zinit light romkatv/powerlevel10k
fi

# Load zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions

# Add in snippets
zinit snippet OMZP::git
# zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found
zinit snippet OMZP::magic-enter
zinit snippet OMZL::key-bindings.zsh        # smart up/down history search
zinit snippet OMZL::grep.zsh                # highlighting
zinit snippet OMZL::functions.zsh           # for omz_urlencode, used by termsupport.zsh
zinit snippet OMZL::termsupport.zsh         # set titlebar

# Better ssh completion
# if you get a PCRE error: https://github.com/zthxxx/jovial/issues/12
zinit light sunlei/zsh-ssh

zinit snippet OMZP::docker-compose          # docker completions
zinit ice as"completion"
zinit snippet https://github.com/docker/cli/blob/master/contrib/completion/zsh/_docker


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

# zinit snippet OMZP::aws
# zinit snippet OMZP::kubectl
# zinit snippet OMZP::kubectx

# Make sure completion system is initialized
autoload -Uz compinit && compinit

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

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'


# set vim as editor
export EDITOR=vim
alias vi='vim'

# map alt-x to kill line (because tmux uses c-k)
bindkey '^[x' kill-line

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

# set up zoxide and use it as cd (if installed
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

    # Load main fzf integration
    source <(fzf --zsh)

    # Load fzf-tab on top
    zinit light Aloxaf/fzf-tab

    # Custom keybind instead of ALT-c/ESC-c
    bindkey '^N' fzf-cd-widget

    # Just as a note, default keybind for scrolling the preview window is shift up/down

    # Defaults for when eza/bat/fd not installed
    : ${FZF_FILE_PREVIEW="head -500 {}"}
    : ${FZF_DIR_PREVIEW="ls --color=always {} | head -500"}

    # Set up a preview that can handle files and directories
    show_file_or_dir_preview="if [ -d {} ]; then $FZF_DIR_PREVIEW; else $FZF_FILE_PREVIEW; fi"
    export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"

    # clear FZF_DEFAULT_OPTS so we don't get duplicates when running under tmux
    unset FZF_DEFAULT_OPTS

    # Tokyonight-night fzf theme
    zinit snippet https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/fzf/tokyonight_night.sh

    # I like orange as the highlight color
    export FZF_DEFAULT_OPTS=$(echo "$FZF_DEFAULT_OPTS" | sed 's/--color=hl+:#2ac3de/--color=hl+:#ff9e64/g; s/--color=hl:#2ac3de/--color=hl:#ff9e64/g')

    # Turn on wrap around
    export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --cycle"

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
    # preview directory's content with eza when completing cd

    # zstyle needs an unexpanded $realpath in place of {}
    zstyle ':fzf-tab:complete:cd:*' fzf-preview ${FZF_DIR_PREVIEW//\{\}/\$realpath}
    zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview ${FZF_DIR_PREVIEW//\{\}/\$realpath}
fi

zinit cdreplay -q

if [[ -n $USE_STARSHIP ]]; then
    # eval "$(oh-my-posh init zsh --config $DOTFILES/oh-my-posh/config.toml)"
    # eval "$(oh-my-posh init zsh --config /usr/local/opt/oh-my-posh/themes/amro.omp.json)"
    eval "$(starship init zsh)"
else
    # To customize prompt, run `p10k configure` or edit ~/dotfiles/.p10k.zsh.
    [[ ! -f $DOTFILES/.p10k.zsh ]] || source $DOTFILES/.p10k.zsh

    typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=magenta
fi
