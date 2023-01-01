# Load any user customizations prior to load
#
# if [ -d $HOME/.zsh.before/ ]; then
#   if [ "$(ls -A $HOME/.zsh.before/)" ]; then
#     for config_file ($HOME/.zsh.before/*.zsh) source $config_file
#   fi
# fi
if [ -d $HOME/dotfiles/zsh/zsh.before/ ]; then
  if [ "$(ls -A  -d $HOME/dotfiles/zsh/zsh.before/)" ]; then
    for config_file ($HOME/dotfiles/zsh/zsh.before/*.zsh) source $config_file
  fi
fi
