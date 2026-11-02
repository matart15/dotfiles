# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

autoload -U compinit
compinit -u

autoload -U colors
colors

PROMPT='%{$fg[yellow]%}[%~]'$'\n''%(?.%{$fg[green]%}\(^o^%)/.%{$fg[red]%}/(^o^%)\)[%n@%m]%#%{$reset_color%} '

REPORTTIME=3

ulimit -c unlimited
ulimit -n 10240

if [ $TERM = "screen" ]; then
  preexec () {
    echo -ne "\ek${1%% *}\e\\"
  }
fi

ZSH_THEME=""
plugins=(git zsh-autosuggestions zsh-syntax-highlighting web-search)
source $ZSH/oh-my-zsh.sh


export DOTFILES_DIR=$HOME/dotfiles
for config_file ($DOTFILES_DIR/zsh/*.zsh) source $config_file



