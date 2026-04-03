#!/bin/bash

set -eux

git submodule init
git submodule update

# Install tmux plugin manager if missing
if [ ! -d ~/.tmux/plugins/tpm ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# .ackrc .editrc .gemrc
for dotfile in  .gdbinit .gitconfig .gitignore .inputrc .p10k.zsh .railsrc .screenrc .tigrc .toprc .vim .vimrc. .tmux.conf .tmuxinator .zprofile .zshenv .zshrc
do
  if [ -e ~/$dotfile ]; then
    rm -fr ~/$dotfile
  fi
  ln -nfs $PWD/$dotfile ~/$dotfile
done
