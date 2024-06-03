ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

## Oh My Zsh Setting
ZSH_THEME="zsh-cam"

# setopt promptsubst

# oh-my-zsh libs
zi light-mode lucid for \
    OMZ::lib/git.zsh \
    OMZ::lib/grep.zsh \
    OMZ::lib/history.zsh \
    OMZ::lib/spectrum.zsh \
    OMZ::lib/functions.zsh \
    OMZ::lib/completion.zsh \
    OMZ::lib/directories.zsh \
    OMZ::lib/key-bindings.zsh \
    OMZ::lib/theme-and-appearance.zsh


# Load my OMZ theme
zi light cameronr/zsh-cam

# Load additional completions
zinit light zsh-users/zsh-completions

# Make sure completion system is initialized
autoload -Uz compinit
compinit

zi load zsh-users/zsh-autosuggestions
zi load zsh-users/zsh-syntax-highlighting

# set up zoxide and use it as cd
eval "$(zoxide init --cmd cd zsh)"

# set up fzf if installed
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export EDITOR=vim
source ~/.local_aliases


# turn off shared history
setopt    appendhistory     # Append history to the history file (no overwriting)
unsetopt  sharehistory      # Don't share history across terminals
setopt    incappendhistory  # Immediately append to the history file, not just when a term is killed


# Shopify Hydrogen alias to local projects
alias h2='$(npm prefix -s)/node_modules/.bin/shopify hydrogen'
