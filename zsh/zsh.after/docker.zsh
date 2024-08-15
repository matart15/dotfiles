# Docker
alias d='docker'
alias dc='docker compose'

# docker completion
autoload -Uz compinit && compinit -i
fpath=(~/.zsh/completion $fpath)
