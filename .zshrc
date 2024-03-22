# CodeWhisperer pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.pre.zsh"
# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
#  ZSH_THEME="robbyrussell"
ZSH_THEME="cam"
DOTFILES=~/dotfiles
ZSH_CUSTOM=$DOTFILES/zsh

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable bi-weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment to change how many often would you like to wait before auto-updates occur? (in days)
# export UPDATE_ZSH_DAYS=13

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"


##### Plugins
#
# OhMyZsh
#
# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git virtualenvwrapper docker aws)

source $ZSH/oh-my-zsh.sh

# zplug start
source $DOTFILES/zplug/init.zsh



# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# zplug end

# Customize to your needs...
export PATH=/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:/usr/local/git/bin:$PLUGIN_PATHS


# virtualenvwrapper installation
# http://virtualenvwrapper.readthedocs.org/en/latest/install.html
if [ -f /usr/local/bin/virtualenvwrapper.sh ]; then
 #  echo "sourcing virtualenv"
  export WORKON_HOME=$HOME/.virtualenvs
  export PROJECT_HOME=$HOME/Dev
  #  source /usr/local/bin/virtualenvwrapper.sh
fi

export EDITOR=vim

source ~/.local_aliases

# CodeWhisperer post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.post.zsh"

eval "$(zoxide init --cmd cd zsh)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# turn off shared history
setopt    appendhistory     # Append history to the history file (no overwriting)
unsetopt  sharehistory      # Don't share history across terminals
setopt    incappendhistory  # Immediately append to the history file, not just when a term is killed
