DOTFILES="${XDG_DATA_HOME:-${HOME}/dotfiles}"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Zinit initialization
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# Load Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Load zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions

# Better ssh completion
# if you get a PCRE error: https://github.com/zthxxx/jovial/issues/12
zinit light sunlei/zsh-ssh

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found
zinit snippet OMZL::key-bindings.zsh        # smart up/down history search
zinit snippet OMZL::grep.zsh                # highlighting
zinit snippet OMZL::functions.zsh           # for omz_urlencode, used by termsupport.zsh
zinit snippet OMZL::termsupport.zsh         # set titlebar

zinit snippet OMZP::docker-compose          # docker completions
zinit ice as"completion"
zinit snippet https://github.com/docker/cli/blob/master/contrib/completion/zsh/_docker

# OMZ doesn't have any configuration for the title when running a command. For the idle title, we could set
# ZSH_THEME_TERM_TAB_TITLE_IDLE / ZSH_THEME_TERM_TITLE_IDLE but that won't help with long
# running commands. To work around this limitation, we copy the function 'title' to 'omz_title'
# so we can intercept it and change the parameters, adding the user/machine if it's not included.
# It might be cleaner to just fork and modify the code but here we are.
# Can set ALWAYS_SHOW_HOST_IN_TITLE to false in .zprofile to prevent this behavior

if [[ "${ALWAYS_SHOW_HOST_IN_TITLE:-true}" == true ]]; then
    functions -c title omz_title
    title () {
        local CMD=$1
        local LINE=$2
        if [[ $1 != *"%m"* ]]; then
            CMD="%n@%m:$1"
        fi
        if [[ $2 != *"%m"* ]]; then
            LINE="%n@%m:$2"
        fi
        omz_title $CMD $LINE
    }
fi

# We also don't need the cwd hook as p10k handles all of that for us (and having this hook
# introduces a visual glitch)
add-zsh-hook -d precmd omz_termsupport_cwd

# zinit snippet OMZP::aws
# zinit snippet OMZP::kubectl
# zinit snippet OMZP::kubectx

# Make sure completion system is initialized
autoload -Uz compinit && compinit

# Set up history
HISTFILE=~/.zhistory
SAVEHIST=100000
HISTSIZE=100000
HISTDUP=erase
setopt    appendhistory        # Append history to the history file (no overwriting)
setopt    sharehistory         # Share history across terminals
setopt    hist_ignore_space    # don't log history with a leading space
setopt    hist_ignore_all_dups # Delete old recorded entry if new entry is a duplicate.
setopt    hist_save_no_dups    # Don't write duplicate entries in the history file.
setopt    hist_ignore_dups     # Don't record an entry that was just recorded again.
setopt    hist_find_no_dups    # Don't write duplicate entries in the history file.

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"


# set vim as editor
export EDITOR=vim
alias vi='vim'

if [[ (( $commands[nvim] )) ]]; then
    export EDITOR=nvim
    alias vim='nvim'

    NVIM_HOME="${XDG_DATA_HOME:-${HOME}/.config/nvim}"
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
    alias ls='eza -F --color=always --icons=always --no-quotes'
    FZF_DIR_PREVIEW='eza -F --color=always --icons=always --no-quotes --tree {} | head -500'
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
if [[ (( $commands[bat] )) ]]; then
    eval $(thefuck --alias fk)
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

    # Tokyonight-night fzf theme
    zinit snippet https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/fzf/tokyonight_night.sh

    # disable sort when completing `git checkout`
    zstyle ':completion:*:git-checkout:*' sort false

    # Disabling groups as I don't really understand them and a unified search feels more natural
    # set descriptions format to enable group support
    # NOTE: don't use escape sequences here, fzf-tab will ignore them
    # zstyle ':completion:*:descriptions' format '[%d]'
    # zstyle ':fzf-tab:*' switch-group '<' '>'

    # set list-colors to enable filename colorizing
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
    # force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
    zstyle ':completion:*' menu no
    # preview directory's content with eza when completing cd
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color=always $realpath'
    zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
fi

zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/dotfiles/.p10k.zsh.
[[ ! -f ~/dotfiles/.p10k.zsh ]] || source ~/dotfiles/.p10k.zsh

