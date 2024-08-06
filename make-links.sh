#!/bin/zsh
# set -x

cd ~

DOTFILES_DIR="${XDG_DATA_HOME:-${HOME}/dotfiles}"

CONFIG_DIR="${XDG_DATA_HOME:-${HOME}/.config}"

# # (.) at end tells zsh to only return files
# for file in $DOTFILES_DIR/.*(.); do
#     echo ln -s $file `basename $file`
# done
#
# # (.) at end tells zsh to only return directories
# for dir in $DOTFILES_DIR/*(/); do
#     echo $dir
# done
#

DOTFILES=(.zshrc .p10k.zsh)

# (.) at end tells zsh to only return files
for file in $DOTFILES; do
    ln -s $DOTFILES_DIR/$file $file
done

# Tmux special case
ln -s $DOTFILES_DIR/tmux/tmux.conf .tmux.conf

DOTFILE_DIRS=(nvim)

# (.) at end tells zsh to only return directories
for dir in $DOTFILE_DIRS; do
    ln -s $DOTFILES_DIR/$dir $CONFIG_DIR/nvim
done
