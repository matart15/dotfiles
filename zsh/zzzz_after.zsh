# Load any custom after code
if [ -d $HOME/.zsh.after/ ]; then
  if [ "$(ls -A $HOME/.zsh.after/)" ]; then
    for config_file ($HOME/.zsh.after/*.zsh) source $config_file
  fi
fi

if [ -d $HOME/.yadr/zsh/zsh.after/ ]; then
  if [ "$(ls -A  -d $HOME/.yadr/zsh/zsh.after/)" ]; then
    for config_file ($HOME/.yadr/zsh/zsh.after/*.zsh) source $config_file
  fi
fi
