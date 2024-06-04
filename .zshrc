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

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found
zinit snippet OMZL::key-bindings.zsh        # smart up/down history search
zinit snippet OMZL::grep.zsh                # highlighting
# zinit snippet OMZP::aws
# zinit snippet OMZP::kubectl
# zinit snippet OMZP::kubectx

# Make sure completion system is initialized
autoload -Uz compinit && compinit

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Set up history
HISTDUP=erase
setopt    appendhistory        # Append history to the history file (no overwriting)
unsetopt  sharehistory         # Don't share history across terminals
setopt    incappendhistory     # Immediately append to the history file, not just when a term is killed
setopt    hist_ignore_space    # don't log history with a leading space
setopt    hist_ignore_all_dups # Delete old recorded entry if new entry is a duplicate.
setopt    hist_save_no_dups    # Don't write duplicate entries in the history file.
setopt    hist_ignore_dups     # Don't record an entry that was just recorded again.
setopt    hist_find_no_dups    # Don't write duplicate entries in the history file.

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# set up fzf if installed
if [ -f ~/.fzf.zsh ]; then
  zinit light Aloxaf/fzf-tab
  source ~/.fzf.zsh
  zstyle ':completion:*' menu no
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
  zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
fi

zinit cdreplay -q

# set vim as editor
export EDITOR=vim

# Load local aliases
[[ ! -f ~/.local_aliases ]] || source ~/.local_aliases

# set up zoxide and use it as cd (if installed
if [ -z `which zoxide` ]; then
  eval "$(zoxide init --cmd cd zsh)"
fi

