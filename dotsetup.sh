#!/bin/bash

set -eux

git submodule init
git submodule update

# Install tmux plugin manager if missing
if [ ! -d ~/.tmux/plugins/tpm ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# .ackrc .editrc .gemrc
for dotfile in  .gdbinit .gitconfig .gitignore .inputrc .railsrc .screenrc .tigrc .toprc .vim .vimrc. .tmux.conf .tmuxinator .zprofile .zshenv .zshrc
do
  if [ -e ~/$dotfile ]; then
    rm -fr ~/$dotfile
  fi
  ln -nfs $PWD/$dotfile ~/$dotfile
done

# Starship configuration is tracked in dotfiles and linked into the standard location.
mkdir -p "$HOME/.config"
if [ -e "$HOME/.config/starship.toml" ] && [ ! -L "$HOME/.config/starship.toml" ]; then
  cp -p "$HOME/.config/starship.toml" "$HOME/.config/starship.toml.backup.$(date +%Y%m%d-%H%M%S)"
fi
ln -sfn "$PWD/starship/starship.toml" "$HOME/.config/starship.toml"
