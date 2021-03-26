#Load themes from yadr and from user's custom prompts (themes) in ~/.zsh.prompts
autoload promptinit
setopt EXTENDED_GLOB
for rcfile in /Users/matar/.yadr/zsh/.zprezto/runcoms/^README.md(.N); do
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
promptinit
