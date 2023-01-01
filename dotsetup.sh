#!/bin/bash

set -eux

git submodule init
git submodule update

# .ackrc .editrc .gemrc
for dotfile in  .gdbinit .gitconfig .gitignore .inputrc .p10k.zsh .railsrc .screenrc .tigrc .toprc .vim .vimrc. .tmux.conf .tmuxinator .zprofile .zshenv .zshrc
do
  if [ -e ~/$dotfile ]; then
    rm -fr ~/$dotfile
  fi
  ln -nfs $PWD/$dotfile ~/$dotfile
done
